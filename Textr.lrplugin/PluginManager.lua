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
      prefs.google_api_key = LOC '$$$/shamurai/textr/gconf=<Please Configure In Google Clound Dashboard>'
   end

   if (prefs.text_length == nil or
       prefs.text_length == "") then
       prefs.text_length = 0
   end

   if (prefs.allow_regex == nil or
       prefs.allow_regex == "") then
       prefs.allow_regex = "^[a-zA-Z0-9]+$"
   end

   if (prefs.img_size == nil or
       prefs.img_size == "") then
       prefs.img_size = "320"
   end
   
   if (prefs.max_imgs == nil or
       prefs.max_imgs == "") then
       prefs.max_imgs = "250"
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
         title = LOC '$$$/shamurai/textr/gdash=Google Cloud Dashboard',
         enabled = true,
         action = function()
            LrHttp.openUrlInBrowser(_G.URL)
         end,
      },
   }

   local t = f:row {
      spacing = f:control_spacing(),
      f:static_text {
         title = LOC '$$$/shamurai/textr/tlength=Exact text length:',
         alignment = 'left',
         -- fill_horizontal = 1,
      },
      f:edit_field {
         immediate = true,
         -- value_to_string = true,
         alignment = 'left',
         fill_horizontal = 1,
         value = LrView.bind('text_length'),
      },
   }

   local u = f:row {
      spacing = f:control_spacing(),
      f:static_text {
         title = LOC '$$$/shamurai/textr/imgsize=Image size to use:',
         alignment = 'left',
         -- fill_horizontal = 1,
      },
      f:edit_field {
         immediate = true,
         value_to_string = true,
         alignment = 'left',
         fill_horizontal = 1,
         value = LrView.bind('img_size'),
      },
   }
   local uu = f:row {
      spacing = f:control_spacing(),
      f:static_text {
         title = LOC '$$$/shamurai/textr/maximgs=Max batch size:',
         alignment = 'left',
         -- fill_horizontal = 1,
      },
      f:edit_field {
         immediate = true,
         value_to_string = true,
         alignment = 'left',
         fill_horizontal = 1,
         value = LrView.bind('max_imgs'),
      },
   }

   local w = f:row {
      spacing = f:control_spacing(),
      f:static_text {
         title = LOC '$$$/shamurai/textr/aregex=Allow Regex:',
         alignment = 'left',
         -- fill_horizontal = 1,
      },
      f:edit_field {
         immediate = true,
         value_to_string = true,
         alignment = 'left',
         fill_horizontal = 1,
         value = LrView.bind('allow_regex'),
      },
   }
   
   local s = {
      title = LOC "$$$/shamurai/textr/pluginName=Textr OCR Tagger",
      bind_to_object = prefs,
      r,
      u,
      t,
      uu,
      w,
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
