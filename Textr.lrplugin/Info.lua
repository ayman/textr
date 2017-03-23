return {
   LrSdkVersion = 5.0,

   LrToolkitIdentifier = 'com.shamurai.textr',
   LrPluginName = LOC "$$$/shamurai/textr/pluginName=Textr OCR",

   LrInitPlugin = 'PluginInit.lua',

   LrMetadataProvider = 'TextrDefinitionFile.lua',
   LrMetadataTagsetFactory = 'TextrTagset.lua',

   LrLibraryMenuItems = {
      title = LOC "$$$/shamurai/textr/menu=Textr OCR",
      file = "OcrText.lua",
      enabledWhen = "photosSelected",
   },

   LrPluginInfoProvider = 'PluginInfoProvider.lua',
   LrPluginInfoUrl = "http://shamurai.com/bin/textr",

   VERSION = { major=0, minor=0, revision=9, build=1490299599 },
}
