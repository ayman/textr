local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrHttp = import 'LrHttp'
local LrStringUtils = import 'LrStringUtils'
local LrView = import 'LrView'
local LrPrefs = import 'LrPrefs'
local LrProgressScope = import 'LrProgressScope'

local JSON = require 'JSON'

local logger = import 'LrLogger'( "Textr" )

logger:enable( 'print' )
-- logger:enable( 'logfile' )
logger:info( "Loading Textr..." )

local ENDPOINT_URL = "https://vision.googleapis.com/v1/images:annotate"
-- TODO: make sure this is not the default slug
local API_KEY = LrPrefs.prefsForPlugin().google_api_key
local TEXT_LENGTH = tonumber(LrPrefs.prefsForPlugin().text_length)

local ALLOW_REGEX = LrPrefs.prefsForPlugin().allow_regex
if ALLOW_REGEX == "" then
   ALLOW_REGEX = "^+$"
end

local IMAGE_SIZE = LrPrefs.prefsForPlugin().img_size
if IMAGE_SIZE == "0" or IMAGE_SIZE == "" then
   IMAGE_SIZE = "320"
end

local MAX_IMGS = tonumber(LrPrefs.prefsForPlugin().max_imgs)
if MAX_IMGS == "0" or IMAGE_SIZE == "" then
   MAX_IMGS = 250
end

local ALPHANUMERIC = "^[a-zA-Z0-9]+$"
local NUMERIC = "^[0-9]+$"
local ALPHA = "^[a-zA-Z]+$"

--------------------------------------------------------------------------------
-- Trim text

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------
-- Make JSON post data for one base 64 image string.

function makeImageData( data )
   local d = "{requests:[{image:{content: \""
      .. data
      .. "\"}, features: [{type:'TEXT_DETECTION', maxResults: 1}]}]}"
   return d
end

--------------------------------------------------------------------------------
-- Make JSON post data for array of base 64 image strings.

function makeImageDataArray( dataArray )
   -- TODO: parameterize maxResults
   local img = "{image:{content: \"%s\"},"
   img = img .. "features: [{type:'TEXT_DETECTION', maxResults: 1}]}"
   local imageData = string.format( img, dataArray[1] )
   for i = 2, #dataArray do
      imageData = imageData .. "," .. string.format( img, dataArray[i] )
   end
   return string.format( "{requests:[%s]}", imageData )
end

--------------------------------------------------------------------------------
-- Simple call HTTP POST with url and data.

function callPOST( url, data )
   return LrHttp.post(
      url .. "?key=" .. API_KEY,
      makeImageData( data ),
      { { field = "Content-Type", value = "application/json" },
        { field = "User-Agent", value = "Textr Plugin 1.0" },
        { field = "Cookie", value = "GARBAGE" } } )
end

--------------------------------------------------------------------------------
-- Simple call HTTP POST with url and data array.

local function callPOSTArray( url, data )
   return LrHttp.post(
      url .. "?key=" .. API_KEY,
      makeImageDataArray(data),
      { { field = "Content-Type", value = "application/json" },
        { field = "User-Agent", value = "Textr Plugin 1.0" },
        { field = "Cookie", value = "GARBAGE" } } )
end

--------------------------------------------------------------------------------
-- Write trace information to the logger.
-- example http://bit.ly/2mVlzTF
LrTasks.startAsyncTask (
   function()
      logger:debug( "Starting Async Task" )
      local progress = LrProgressScope { title="Textr" }
      progress:setCaption( LOC "$$$/shamurai/textr/fetch=Fetching Catalog" )
      local catalog = LrApplication.activeCatalog()
      local selectedPhotos = catalog:getTargetPhotos() -- (type: LrPhoto{})
      local minSize = 1
      local maxSize = MAX_IMGS
      -- not too many for now
      if #selectedPhotos > maxSize or #selectedPhotos < minSize then
         local message = LOC '$$$/shamurai/textr/toomany=Too Many (%d photos).'
         local info = LOC '$$$/shamurai/textr/exceeds== %d photos is the max.'
         LrDialogs.message( string.format( message, #selectedPhotos ),
                            string.format( info, maxSize ),
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

      logger:debug( "Generating Hashes" )
      progress:setCaption( LOC "$$$/shamurai/textr/hash=Generating Hashes" )
      for i = 1, #selectedPhotos do
         local photo = selectedPhotos[i]
         photo:requestJpegThumbnail( IMAGE_SIZE, nil, storeB64 )
         progress:setPortionComplete( i, 2 * #selectedPhotos )
         LrTasks.yield()
      end

      -- good ref http://bit.ly/2mVlzTF
      -- https://forums.adobe.com/message/3948416#3948416
      logger:debug( "Calling Google Cloud" )
      progress:setCaption( LOC "$$$/shamurai/textr/call=Calling Google Cloud" )
      local response = callPOSTArray( ENDPOINT_URL, b64Data )

      progress:setCaption( LOC "$$$/shamurai/textr/decode=Decoding JSON" )
      local foundTags = {}
      local ocr = JSON:decode( response )
      for i = 1, #ocr.responses do
         local annotations = ocr.responses[i].textAnnotations
         if annotations ~= nil then
            local tagsText = ""
            for i, text in ipairs( annotations ) do
               if string.match( text.description, ALLOW_REGEX ) then
                  if TEXT_LENGTH <= 0 then
                     tagsText = tagsText .. text.description .. " "
                  elseif  #text.description == TEXT_LENGTH  then
                     tagsText = tagsText .. text.description .. " "
                  else
                     tagsText = ""
                  end
               end
            end
            foundTags[#foundTags + 1] = trim( tagsText )
            logger:debugf( "Photo: %s OCR Tag: %s", i, foundTags[i] )            
         end
      end

      local addOcrTags = function ()
         logger:debug( "Adding OCR Tags" )
         progress:setCaption( LOC "$$$/shamurai/textr/adding=Adding OCR Tags" )
         for i = 1, #selectedPhotos do
            selectedPhotos[i]:setPropertyForPlugin( _PLUGIN,
                                                    'textrFoundText',
                                                    foundTags[i] )
            progress:setPortionComplete( #selectedPhotos + i,
                                         2 * #selectedPhotos )
            logger:debugf( "Photo: %s OCR Tag: %s", i, foundTags[i] )
         end
         progress:done()
         logger:info( "Textr done" )
      end
      
      local s = catalog:withWriteAccessDo(
         LOC "$$$/shamurai/textr/add=Add OCR Tags",
         addOcrTags )
      logger:debug( s )
   end
)
