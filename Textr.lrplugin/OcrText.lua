local LrApplication = import 'LrApplication'   
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'
local LrHttp = import 'LrHttp'
local LrStringUtils = import 'LrStringUtils'
local LrView = import 'LrView'
local LrPrefs = import 'LrPrefs'

local JSON = require 'JSON'

-- local log = Lr.Logger()
-- log:enable('print')
-- log:info("Loading module...")

local ENDPOINT_URL = "https://vision.googleapis.com/v1/images:annotate"
local API_KEY = LrPrefs.prefsForPlugin().google_api_key

LrTasks.startAsyncTask (
   function()          
      -- Get the active LR catalog.
      catalog = LrApplication.activeCatalog()   
      -- Get the photo currently selected by the user. (type: LrPhoto)
      selectedPhoto = catalog:getTargetPhoto()
      selectedPhotos = catalog:getTargetPhotos()

      -- if selectedPhoto is nil then selectedPhotos would be the
      -- WHOLE filmstrip..we dont want that.

      -- https://forums.adobe.com/message/3948416#3948416
      
      local holdRefObj = 1
      holdRefObj = selectedPhoto:requestJpegThumbnail(
         320,
         nil,
         function(dat, err)
            if dat == nil then
               LrDialogs.message("nil data")
            else
               local b64 = LrStringUtils.encodeBase64(dat)
               local response = callPOST(ENDPOINT_URL, b64)
               local ocr = JSON:decode(response)
               local annotations = ocr.responses[1].textAnnotations
               if annotations == nil then
                  -- no text found
                  return
               end
               -- TODO: Check if its an alphanumeric thing (no just
               -- strings of symbols) - can make this a setting
               -- defaulted on.
               local tagsText = ""
               for i, text in ipairs(annotations) do
                  tagsText = tagsText .. text.description .. " "
               end
               LrDialogs.message(trim(tagsText))
            end
         end
      )      
   end
)

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function makeImageData( data )
   d = "{requests:[{image:{content: \""
      .. data
      .. "\"}, features: [{type:'TEXT_DETECTION', maxResults: 1}]}]}"
   return d
end     

function callPOST( url, data )
   return LrHttp.post(
      url .. "?key=" .. API_KEY,
      makeImageData(data),
      {  { field = "Content-Type", value = "application/json" },
         { field = "User-Agent", value = "Textr Plugin 1.0" },
         { field = "Cookie", value = "GARBAGE" } } )
end
