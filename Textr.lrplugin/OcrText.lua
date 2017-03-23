local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrHttp = import 'LrHttp'
local LrPrefs = import 'LrPrefs'
local LrProgressScope = import 'LrProgressScope'
local LrStringUtils = import 'LrStringUtils'
local LrTasks = import 'LrTasks'
local LrView = import 'LrView'

local JSON = require 'JSON'
local LOGGER = import 'LrLogger'( "Textr" )

-- write to MacOS Console:system.log
LOGGER:enable( 'print' )
LOGGER:info( "Loading Textr..." )

local ENDPOINT_URL = _G.ENDPOINT_URL
local API_KEY = LrPrefs.prefsForPlugin().google_api_key
if API_KEY == "" or API_KEY == nil then
   LrDialogs.showError( _G.API_KEY_EMPTY )
   return
end

local TEXT_LENGTH = tonumber( LrPrefs.prefsForPlugin().text_length )

local ALLOW_REGEX = LrPrefs.prefsForPlugin().allow_regex
if ALLOW_REGEX == "" then
   ALLOW_REGEX = "^+$"
end

local IMAGE_SIZE = LrPrefs.prefsForPlugin().img_size
if IMAGE_SIZE == "0" or IMAGE_SIZE == "" then
   IMAGE_SIZE = "320"
end

local MAX_IMGS = tonumber( LrPrefs.prefsForPlugin().max_imgs )
if MAX_IMGS == "0" or IMAGE_SIZE == "" then
   MAX_IMGS = 250
end

--------------------------------------------------------------------------------
-- Trim text

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------
-- Make JSON post data for one base 64 image string.

-- local function makeImageData( data )
--    local d = "{requests:[{image:{content: \""
--       .. data
--       .. "\"}, features: [{type:'TEXT_DETECTION'}]}]}"
--    return d
-- end

--------------------------------------------------------------------------------
-- Make JSON post data for array of base 64 image strings.

local function makeImageDataArray( dataArray )
   local img = "{image:{content: \"%s\"},"
   img = img .. "features: [{type:'TEXT_DETECTION'}]}"
   local imageData = string.format( img, dataArray[1] )
   for i = 2, #dataArray do
      imageData = imageData .. "," .. string.format( img, dataArray[i] )
   end
   return string.format( "{requests:[%s]}", imageData )
end

--------------------------------------------------------------------------------
-- Simple call HTTP POST with url and data.

-- local function callPOST( url, data )
--    return LrHttp.post(
--       url .. "?key=" .. API_KEY,
--       makeImageData( data ),
--       {
--          { field = "Content-Type", value = "application/json" },
--          { field = "User-Agent", value = "Textr Plugin 1.0" }
--       }
--    )
-- end

--------------------------------------------------------------------------------
-- Simple call HTTP POST with url and data array.

local function callPOSTArray( url, data )
   return LrHttp.post(
      url .. "?key=" .. API_KEY,
      makeImageDataArray(data),
      {
         { field = "Content-Type", value = "application/json" },
         { field = "User-Agent", value = "Textr Plugin 1.0" }
      }
   )
end

--------------------------------------------------------------------------------

-- local function getInt( v, s )
--    if s == nil then
--       return 0
--    else
--       LOGGER:debug(v)
--       LOGGER:debug(v.img_size)
--       LOGGER:debug(s)      
--       return math.floor(tonumber(s))
--    end
-- end

--------------------------------------------------------------------------------
-- Execution block.

local f = LrView.osFactory()
local prefs = LrPrefs.prefsForPlugin();
local result = LrDialogs.presentModalDialog(
   {
      title = _G.PLUGIN_NAME,
      resizeable = false,
      contents = f:column {
         bind_to_object = prefs,
         f:group_box {
            title = _G.SETTINGS,
            f:row {
               spacing = f:control_spacing(),
               f:static_text {
                  title = _G.THUMBSIZE,
                  alignment = 'left',
               },
               f:edit_field {
                  immediate = true,
                  -- string_to_value = getInt,
                  increment = 32,
                  large_increment = 640,
                  precision = 0,
                  min = 32,
                  max = 4096,
                  alignment = 'right',
                  width_in_digits = 4,
                  value = LrView.bind('img_size'),
               },
               f:static_text {
                  title = _G.ALLOW_REGEX,
                  alignment = 'left',
               },
               f:combo_box {
                  items = { "^[a-zA-Z0-9]+$", "^[0-9]+$", "^[a-zA-Z]+$" },
                  tooltip = _G.COMBO_TIP,
                  immediate = true,
                  width_in_digits = 14,
                  alignment = 'right',
                  value = LrView.bind('allow_regex'),
               },
               f:static_text {
                  title = _G.MATCHED_LENGTH,
                  alignment = 'left',
               },
               f:edit_field {
                  increment = 1,
                  large_increment = 2,
                  immediate = true,
                  -- string_to_value = getInt,
                  precision = 0,
                  min = 0,
                  max = 10,
                  alignment = 'right',
                  width_in_digits = 3,
                  value = LrView.bind('text_length'),
               },
            },
         },
      },
      actionVerb = _G.OCR
   }
)

if result ~= 'ok' then
   -- Cancelled, put our variables back like they were.
   prefs.img_size = IMAGE_SIZE
   prefs.allow_regex = ALLOW_REGEX
   prefs.text_length = TEXT_LENGTH
else
   IMAGE_SIZE = tonumber(prefs.img_size)
   ALLOW_REGEX = prefs.allow_regex
   TEXT_LENGTH = tonumber(prefs.text_length)
   LrTasks.startAsyncTask (
      function()
         LOGGER:debug( "Starting Async Task" )
         local progress = LrProgressScope { title=_G.PLUGIN_NAME }
         progress:setCaption( _G.FETCHING )
         local catalog = LrApplication.activeCatalog()
         local selectedPhotos = catalog:getTargetPhotos()
         local minSize = 1
         local maxSize = MAX_IMGS
         if #selectedPhotos > maxSize or #selectedPhotos < minSize then
            LrDialogs.message( string.format( _G.TOOMANY, #selectedPhotos ),
                               string.format( _G.EXCEEDS, maxSize ),
                               'warning' )
            return
         end

         -- set an array in scope to hold the base 64 data
         local b64Data = {}

         -- callback function to store encoded images
         local storeB64 = function( jpg, err )
            if err == nil then
               -- we should prob store like the filename and the b64 data
               b64Data[#b64Data + 1] = LrStringUtils.encodeBase64( jpg )
            else
               b64Data[#b64Data + 1] = ""
            end
         end

         LOGGER:debug( "Generating Hashes" )
         progress:setCaption( _G.GEN_HASHES )
         for i = 1, #selectedPhotos do
            local photo = selectedPhotos[i]
            photo:requestJpegThumbnail( IMAGE_SIZE, nil, storeB64 )
            progress:setPortionComplete( i, 2 * #selectedPhotos )
            LrTasks.yield()
         end

         -- good ref http://bit.ly/2mVlzTF
         LOGGER:debug( "Calling Google Cloud" )
         progress:setCaption( _G.CALL_CLOUD )
         local response = callPOSTArray( ENDPOINT_URL, b64Data )

         progress:setCaption( _G.DECODE )
         local foundTags = {}
         -- LOGGER:debug("response: " .. string.gsub(response, "\n", ""))
         local ocr = JSON:decode( response )
         for i = 1, #ocr.responses do
            local annotations = ocr.responses[i].textAnnotations
            if annotations ~= nil then
               local tagsSet = {}
               for j, text in ipairs( annotations ) do
                  if string.match( text.description, ALLOW_REGEX ) then
                     if TEXT_LENGTH <= 0 or #text.description == TEXT_LENGTH then
                        tagsSet[trim(text.description)] = true
                     end
                  end
               end
               local tagsText = ""
               for key in pairs(tagsSet) do
                  tagsText = tagsText .. " " .. key
               end
               foundTags[#foundTags + 1] = trim( tagsText )
               LOGGER:debugf( "Photo: %s OCR Tag: %s", i, foundTags[i] )
            end
         end

         local addOcrTags = function ()
            LOGGER:debug( "Adding OCR Tags" )
            progress:setCaption( _G.ADDING )
            for i = 1, #selectedPhotos do
               selectedPhotos[i]:setPropertyForPlugin( _PLUGIN,
                                                       'textrFoundText',
                                                       foundTags[i] )
               progress:setPortionComplete( #selectedPhotos + i,
                                            2 * #selectedPhotos )
               LOGGER:debugf( "Photo: %s OCR Tag: %s", i, foundTags[i] )
            end
            progress:done()
            LOGGER:info( "Textr done" )
         end

         local s = catalog:withWriteAccessDo( _G.ADD, addOcrTags )
         LOGGER:debug( s )
      end
   )
end
