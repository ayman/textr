return {
   metadataFieldsForPhotos = {
      {
         id = 'siteId',
      },
      -- {
      --    id = 'myString',
      --    title = LOC "$$$/Textr/Fields/MyString=My String",
      --    dataType = 'string',
      --    searchable = false,
      --    version = 3
      -- },
      {
         id = 'myboolean',
         title = "Found Tag",
         dataType = 'enum',
         values = {
            {
               value = 'true',
               title = LOC "$$$/Textr/Fields/Display/True=Searchable",
            },
            {
               value = nil,
               title = LOC "$$$/Textr/Fields/Display/False=Off",
            },
         },
         defaultValue = false,
         version = 5,
      },
   },
   schemaVersion = 4,
}
