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
   local f = LrView.osFactory();
   local prefs = LrPrefs.prefsForPlugin();

   if (prefs.text_length == nil or
       prefs.text_length == "") then
       prefs.text_length = 0
   end

   if (prefs.allow_regex == nil or
       prefs.allow_regex == "") then
--       prefs.allow_regex = "^[a-zA-Z0-9]+$"
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
         title = LOC "$$$/shamurai/textr/pluginName=Textr OCR Tagger",
         bind_to_object = prefs,
         f:group_box {
            title = "About",
            f:row{
               f:static_text {
                  title = "Recognize text in photos using the Google Cloud Vision API and add a searchable field for the photos. This came about as I was listening to the PetaPixel Podcast #57 and someone had a question about an automated way to tag race bib numbers in Lightroom. I thought it shouldn't be that hard to whip up in today's age...and here we are.",
                  alignment = 'left',
                  width_in_chars = 58,
                  height_in_lines = -1,
                  fill_horizontal = 1,
               },
            },
         },
         f:group_box {
            title = "Configuration",
            f:row {
               spacing = f:control_spacing(),
               f:static_text {
                  title = 'API Key (CLI):',
                  alignment = 'left',
               },
               f:edit_field {
                  immediate = true,
                  value_to_string = true,
                  alignment = 'left',
                  fill_horizontal = 1,
                  width_in_digits = 40,
                  placeholder_value = LOC "$$$/shamurai/textr/gconf=<Please Configure In Google Clound Dashboard>",
                  tooltip = LOC "$$$/shamurai/textr/apifield=Should be a long API key of random letters and numbers.", 
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
            },
            f:row {
               spacing = f:control_spacing(),
               f:static_text {
                  title = LOC '$$$/shamurai/textr/imgsize=Thumb size:',
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
                  title = LOC '$$$/shamurai/textr/maximgs=Batch size:',
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
               f:static_text {
                  title = LOC '$$$/shamurai/textr/aregex=Allow Regex:',
                  alignment = 'left',
               },
               f:combo_box {
                  items = { "^[a-zA-Z0-9]+$", "^[0-9]+$", "^[a-zA-Z]+$" },
                  tooltip = "Numbers & Letters: ^[a-zA-Z0-9]+$\nNumbers: ^[0-9]+$\nLetters: ^[a-zA-Z]+$",
                  immediate = true,
                  width_in_digits = 12,
                  alignment = 'right',
                  fill_horizontal = 1,
                  value = LrView.bind('allow_regex'),
               },            
               f:static_text {
                  title = LOC '$$$/shamurai/textr/tlength=Matched length:',
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
         -- f:separator {
         --    fill_horizontal = 1
         -- },        
         f:row {
            f:static_text {
               title = 'By: ',
            },
            f:static_text {
               title= LOC 'David A. Shamma.',
               fill_horizontal = 1,
            },
            f:push_button {
               width = 150,
               title = 'Twitter: @ayman',
               enabled = true,
               action = function()
                  LrHttp.openUrlInBrowser("http://twitter.com/ayman")
               end,
            },            
            f:push_button {
               width = 150,
               title = 'Web: shamurai.com',
               enabled = true,
               action = function()
                  LrHttp.openUrlInBrowser(_G.Shamurai)
               end,
            },            
         },         
         f:row {
            f:static_text {
               title = 'Support: ',
            },
            f:static_text {
               title = _G.Support,
               width_in_chars = 35,
               height_in_lines = -1,
               fill_horizontal = 1,
            },
            f:spacer {
               width = 5,
            },
            f:push_button {
               width = 150,
               title = LOC '$$$/shamurai/textr/gitdash=Textr on Github',
               enabled = true,
               action = function()
                  LrHttp.openUrlInBrowser(_G.GIT_URL)
               end,
            },            
         },
         f:row {
            f:static_text {
               title = 'Donate: ',
            },
            f:static_text {
               title = _G.Donate,
               width_in_chars = 35,
               height_in_lines = -1,
               fill_horizontal = 1,
            },
            f:spacer {
               width = 5,
            },            
            f:push_button {
               width = 150,
               title = LOC '$$$/shamurai/textr/donateb=Donate to 100Cameras',
               enabled = true,
               action = function()
                  LrHttp.openUrlInBrowser(_G.DONATE_URL)
               end,
            },            
         },
      }
   }
end

function PluginManager.sectionsForBottomOfDialog(viewFactory, properties)
   local f = LrView.osFactory();   
   return {
      {
         title = LOC "$$$/shamurai/textr/license=License",
         bind_to_object = prefs,
         f:row {
            spacing = f:control_spacing(),
            f:static_text {
               title = "MIT License\n\nCopyright (c) 2017 David A. Shamma\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
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
