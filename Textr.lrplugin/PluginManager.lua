local LrColor = import  "LrColor"
local LrHttp = import "LrHttp"
local LrPrefs = import 'LrPrefs'
local LrView = import "LrView"

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

PluginManager = {}

function PluginManager.sectionsForTopOfDialog(viewFactory, properties)
   local f = viewFactory;
   local prefs = LrPrefs.prefsForPlugin();

   if (prefs.text_length == nil or
       prefs.text_length == "") then
       prefs.text_length = 0
   end

   if (prefs.allow_regex == nil or
       prefs.allow_regex == "") then
      prefs.allow_regex = "^.+$"
   end

   if (prefs.img_size == nil or
       prefs.img_size == "") then
       prefs.img_size = 320
   end

   if (prefs.max_imgs == nil or
       prefs.max_imgs == "") then
       prefs.max_imgs = 250
   end

   return {
      {
         title = _G.plugin_name,
         bind_to_object = prefs,
         f:row {
            fill_horizontal = 1,
            f:column {
               spacing = f:control_spacing(),
               f:picture {
                  value = _PLUGIN:resourceId( 'TextrLogo.png' ),
                  frame_width = 1,
                  frame_color = LrColor( 0, 0, 0 ),
                  tooltip = "Textr will find 32481 and 20386\nfrom this SF Bay to Breakers 2007 photo",
                  visible = true,
                  fill_vertical = 1,
               },
            },
            f:column {
               spacing = f:control_spacing(),
               f:static_text {
                  title = _G.PLUGIN_NAME,
                  font = "<system/bold>",
                  alignment = 'left',
                  size = 'regular'
               },
               f:row {
                  f:static_text {
                     title = _G.BY_LABEL .. ' David A. Shamma',
                     fill_horizontal = 1,
                  },
                  f:push_button {
                     width = 160,
                     title = 'Twitter: @ayman',
                     enabled = true,
                     action = function()
                        LrHttp.openUrlInBrowser("http://twitter.com/ayman")
                     end,
                  },
               },
               f:static_text {
                  title = _G.ABOUT_TEXT,
                  alignment = 'left',
                  width = 325,
                  height_in_lines = -1,
                  fill_horizontal = -1,
               },
            },
         },
         f:group_box {
            title = _G.CONF,
            fill_horizontal = 1,
            f:row {
               spacing = f:control_spacing(),
               f:static_text {
                  title = _G.API_KEY_TITLE,
                  alignment = 'left',
               },
               f:edit_field {
                  immediate = true,
                  value_to_string = true,
                  alignment = 'left',
                  fill_horizontal = 1,
                  width_in_digits = 44,
                  placeholder_value = _G.GCONF,
                  tooltip = _G.API_TIP,
                  value = LrView.bind('google_api_key'),
               },
               f:push_button {
                  width = 155,
                  title = _G.GDASH,
                  enabled = true,
                  action = function()
                     LrHttp.openUrlInBrowser(_G.URL)
                  end,
               },
            },
            f:row {
               f:static_text {
                  title = _G.BATCHSIZE,
                  alignment = 'left',
               },
               f:edit_field {
                  immediate = true,
                  increment = 1,
                  large_increment = 10,
                  string_to_value = getInt,
                  validate = getValidInt,
                  precision = 0,
                  min = 1,
                  max = 1000,
                  alignment = 'right',
                  width_in_digits = 3,
                  value = LrView.bind('max_imgs'),
               },
            },
         },
         f:group_box {
            title = _G.SETTINGS,
            fill_horizontal = 1,
            f:row {
               spacing = f:control_spacing(),
               f:static_text {
                  title = _G.THUMBSIZE,
                  alignment = 'left',
               },
               f:edit_field {
                  immediate = true,
                  string_to_value = getInt,
                  increment = 120,
                  precision = 0,
                  min = 120,
                  max = 2048,
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
                  tooltip = "Numbers & Letters: ^[a-zA-Z0-9]+$\nNumbers: ^[0-9]+$\nLetters: ^[a-zA-Z]+$",
                  immediate = true,
                  width_in_digits = 14,
                  fill_horizontal = 1,
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
                  string_to_value = getInt,
                  precision = 0,
                  min = 0,
                  max = 10,
                  alignment = 'right',
                  width_in_digits = 3,
                  value = LrView.bind('text_length'),
               },
            },
         },
         f:separator {
            fill_horizontal = 1
         },
         f:row {
            spacing = f.control_spacing(),
            f:column {
               f:static_text {
                  width = 44,
                  alignment = 'right',
                  title = _G.SUPPORT_LABEL,
               },
            },
            f:column {
               f:static_text {
                  title = _G.SUPPORT,
                  width_in_chars = 37,
                  height_in_lines = -1,
                  fill_horizontal = 1,
               },
            },
            f:column {
               f:push_button {
                  width = 150,
                  title = _G.GIT_BUTTON,
                  enabled = true,
                  action = function()
                     LrHttp.openUrlInBrowser(_G.GIT_URL)
                  end,
               },
            },
         },
         f:row {
            spacing = f.control_spacing(),
            f:column {
               f:static_text {
                  width = 44,
                  alignment = 'right',
                  title = _G.DONATE_LABEL,
               },
            },
            f:column {
               f:static_text {
                  title = _G.DONATE_TEXT,
                  width_in_chars = 37,
                  height_in_lines = -1,
                  fill_horizontal = 1,
               },
            },
            f:column {
               f:push_button {
                  width = 150,
                  title = _G.DONATE_BUTTON,
                  enabled = true,
                  action = function()
                     LrHttp.openUrlInBrowser(_G.DONATE_URL)
                  end,
               },
            },
         },
      }
   }
end

function PluginManager.sectionsForBottomOfDialog(viewFactory, properties)
   local f = LrView.osFactory();
   return {
      {
         title = _G.LICENSE_LABEL,
         bind_to_object = prefs,
         f:row {
            spacing = f:control_spacing(),
            f:static_text {
               title = _G.MIT_LICENSE,
               width_in_chars = 50,
               height_in_lines = -1,
               fill_horizontal = 1,
               fill_vertical = 1,
            },
         },
      }
   }
end

local function endDialog(properties)
   local prefs = LrPrefs.prefsForPlugin()
   prefs.google_api_key = trim(properties.google_api_key)
   prefs.text_length = trim(text_length)
   prefs.allow_regex = trim(allow_regex)
   prefs.img_size = trim(img_size)
   prefs.max_imgs = trim(max_imgs)
end

local function getInt( v, s )
   return math.floor(tonumber(s))
end

local function getValidInt( v, val )
   n = tonumber(val)
   if n then
      return { true, math.floor(n) }
   else
      return { false, 320, "Not a valid number." }
   end
end

return {
   sectionsForTopOfDialog = sectionsForTopOfDialog,
   sectionsForBottomOfDialog = sectionsForBottomOfDialog,
   endDialog = endDialog
}
