Point the file selector below to a geographic file (shapefile or geojson)
containing the results of ARC's cultural/environmental ArcGIS-based scores. This
must contain (at least) the following fields:

  - `project`: The name of the project
  - `Acres`: The acreage of the project buffer
  - `COUNT`: The count of conflicts with environmental/cultural layers
  - `WgtdMean`: The weighted mean counts per acre


Additionally, it is possible for a project in this file to be composed of more
than one element. In this case, each element must have the proper `project`
field.
