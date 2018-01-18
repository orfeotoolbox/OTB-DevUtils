Study on OSSIM removal from OTB
=================================

Impact on modules and dependencies
----------------------------------

* Third Party:

  * OTBOssim : removed
  * OTBOssimPlugins : removed, code revamped into an other module
  * OTBGeoTiff : removed (was only useful for Ossim)
  * OTBOpenThreads : removed (only used by Ossim and OTBOpenThreadsAdapters

* Other groups:

  * OTBOpenThreadsAdapters : to be removed, only used for a Sleep()
    function in a test in module IO/Carto
  * OTBTransform:

    * This module should recieve the code dedicated to sensor models and transforms
    * 2 tests using directly Ossim need to be reworked.

  * OTBOSSIMAdapters : to be refactored and dispatched in different modules

In the end, 3 mandatory dependencies can be removed.

Dispatch de OTBOSSIMAdapters
----------------------------

otbDateTimeAdapter
~~~~~~~~~~~~~~~~~~

Role: store a date/time from a Iso8601 string, access Year/Month/.../seconds, compute time delta

Actions: move to OTBCommon or OTBMetadata, has to be implemented using STL or BOOST, impacts with
the  RFC on time series (check with Jordi)

otbDEMConvertAdapter
~~~~~~~~~~~~~~~~~~~~

Role: convert a geo-referenced DEM into a general raster image. Class only used by application
DEMConvert. Maybe something is done about the resolution.

Actions: not sure this class is still usefull, a simple Convert/Quicklook/RigidTransformResample would to the same thing. IMO -> to be removed.

otbDEMHandler
~~~~~~~~~~~~~

Role:

* Open a DEM directory (with SRTM tiles, single GeoTIFF file, ...)
* Open a geoid file (\*.egm)
* Handle a default elevation setting
* Provide the elevation at any coordinates (lon/lat)

Actions: there is nothing really equivalent in GDAL. If we go for a custom development:

* Create a DEM directory reader, maybe through a (in-memory) VRT. SRTM tiles are added to 
  the VRT. If they are still in a zip, they can be accessed with /vsizip/. Then a single 
  ImageFileReader can open the VRT and retrieve elevation data.
* Performance: how to handle caching for elevation data? Will GDAL do it?
* The geoid file can be opened in a separate ImageFileReader. 
* The new DEMHandler will then interpolate data using DEM and geoid readers.
* Design: is-it still relevant to use a singleton?

otbEllipsoidAdapter
~~~~~~~~~~~~~~~~~~~

Role: convert geographic to geocentric coordinates.

Actions:

* Move to OTBTransform
* Replace ossimEllipsoid by a hardcoded formula (using ellipsoid parameters a and b) or use a
  GDALCoordinateTransform between a Geographic SRS and a Geocentric SRS.

otbFilterFunctionValues
~~~~~~~~~~~~~~~~~~~~~~~

Role: store a spectral response profile, no dependency to Ossim

Actions: just move it to Core/Metadata

otbGeometricSarSensorModelAdapter
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Role: wrapper class around ossimGeometricSarSensorModel, gives access position, speed and
date-time for each line.

Actions: as the class ossimGeometricSarSensorModel is progressively replaced by
ossimSarSensorModel, the replacement of ossimGeometricSarSensorModel can be discussed.
Anyway, the adapter class will be removed. If a replacement class is ported in OTB, it
will be used directly. 

otbImageKeywordList
~~~~~~~~~~~~~~~~~~~

Role: store a metadata dictionary (map<string,string>), import/export to ossimKeywordlist,
convert to GDAL RPC structure, read geometry and models

Actions:

* Remove the import/export function to ossimKeywordlist
* Move this class to OTBMetadata
* Create a GEOM reader class
* Refactor the geometry reading functions to use new sensor models and projections
  and put them in OTBTransform or in a IO module
* If we keep the current design, this class will be used as a replacement
  for ossimKeywordlist in refactored loadState/saveState functions

otbMapProjectionAdapter
~~~~~~~~~~~~~~~~~~~~~~~

Role: adapter for ossim::Projection, also contain Utils::GetZoneFromGeoPoint()

Actions:

* Remove the adapter class
* Refactor GenericMapProjection to use OGRCoordinateTransformation
* move Utils::GetZoneFromGeoPoint() to GenericMapProjection and refactor it with GDAL
  or custom code (the base formula is simple, there are only 2 exceptions)

otbMetadataKey
~~~~~~~~~~~~~~

Role: just a definition of the MetadataDictionary fields

Actions: No real adaptation to do, can be moved to OTBMetadata

otbPlatformPositionAdapter
~~~~~~~~~~~~~~~~~~~~~~~~~~

Role:

* another wrapper class around ossimGeometricSarSensorModel (see otbGeometricSarSensorModelAdapter)
* provides a time to line conversion
* Currently not used in OTB

Actions:

* adapter class to be removed
* make sure the replacement class has a function to convert time into line.

otbRPCSolverAdapter
~~~~~~~~~~~~~~~~~~~

Role: solve a RPC modelling using a set of GCPs

Actions:

* move the class to OTBTransform
* find a solver in GDAL, ITK or in VCL (least square, Levenberg Marquardt, ...)
* the RPC transform can be supplied by GDALRPCTransform (see alg/gdal_rpc.cpp)
* GDAL can already fit a polynomial transform using a set of GCP (GDALCreateGCPTransform)
  , least square used, could be useful for initialization

otbSarSensorModelAdapter
~~~~~~~~~~~~~~~~~~~~~~~~

Role: wrapper around ossimSarSensorModel, provides deburst processing functions

Actions: to be removed, replaced by the refactoring of ossimSarSensorModel

otbSensorModelAdapter
~~~~~~~~~~~~~~~~~~~~~

Role: wrapper class for ossimProjection (and all sensor models), provides forward
and inverse transform, refinement using GCP, uses the DEMHandler.

Actions:

* to be replaced by the base class of the refactored sensor models.
* for the model refinement, the same adjustment parameters as Ossim can be implemented
  in the new projection base class. It should not be related to RPC.

Metadata parsing
----------------

Refactoring of sensor models
----------------------------

