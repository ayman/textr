local LrPrefs = import 'LrPrefs'
local LrView = import "LrView"
local LrHttp = import "LrHttp"
local bind = import "LrBinding"
local app = import 'LrApplication'

local function getOrDefault(value, default)
   if value == nil then
      return default
   end
   return value
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

PluginManager = {}

function PluginManager.sectionsForTopOfDialog(viewFactory, properties)
   -- local f = viewFactory;
   
   local f = LrView.osFactory();
   local prefs = LrPrefs.prefsForPlugin();
   
   if (prefs.google_api_key == nil or
       prefs.google_api_key == "") then
      prefs.google_api_key = "<Please Configure In Google Clound Dashboard>"
   end

   local r = f:row {  
      spacing = f:control_spacing(),
      f:static_text {
         title = 'API Key (CLI):',
         alignment = 'left',
         -- fill_horizontal = 1,
      },
      f:edit_field {
         immediate = true,
         value_to_string = true,
         alignment = 'left',
         fill_horizontal = 1,
         value = LrView.bind('google_api_key'),
      },
      f:push_button {
         width = 150,
         title = 'Google Cloud Dashboard',
         enabled = true,
         action = function()
            LrHttp.openUrlInBrowser(_G.URL)
         end,
      },
   }

   local s = {
      title = "Textr OCR Tagger",
      bind_to_object = prefs,
      r,
   }
   
   return {s}
end

local function endDialog(properties)
   local prefs = LrPrefs.prefsForPlugin()
   prefs.google_api_key = trim(properties.google_api_key)
end

return {
   sectionsForTopOfDialog = sectionsForTopOfDialog,
   endDialog = endDialog
}


-- function PluginManager.sectionsForTopOfDialog( f, p )
--    local s = {
--       {
--          title = "Configure Google Cloud API",
--          f:row {
--             spacing = f:control_spacing(),

--             f:static_text {
--                title = 'API Key (CLI):',
--                alignment = 'left',
--                -- fill_horizontal = 1,
--             },

--             f:edit_field {
--                immediate = true,
--                value_to_string = true;
--                alignment = 'left',
--                fill_horizontal = 1,
--                -- value = _G.google_api_key,
--                -- value = LrView.bind('google_api_key'),
--             },

--             f:push_button {
--                width = 150,
--                title = 'Google Cloud Dashboard',
--                enabled = true,
--                action = function()
--                   LrHttp.openUrlInBrowser(_G.URL)
--                end,
--             },
--          },
--       },
--    }
--    return s
-- end

-- table.insert(sections, sectionCustom)

