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

Metadata parsing
----------------

Currently, metadata is parsed from each child class of ossimSensorModel. This metadata
is then exported into an ImageKeywordlist. On the other hand, the otbXXXImageMetadataInterface
is designed to expose this metadata in a generic way. It would make sense to move the
metadata-parsing code from ossimSensorModels into otbXXXImageMetadataInterface ("IMI"), and have 
a single class that represents a sensor metadata.

I have been thinking about a more generic way to parse metadata. In the end, there are
always corner cases where the metadata is read from some file and then transformed before
being recorded into the ImageKeywordlist. I propose the following workflow to replace the
current function ``ReadGeometryFromImage()``:

1. We use a classic IMIFactory to find if a given IMI (associated to a given sensor) can read
   a product. For a given input image filename, each IMI can return the list of associated
   metadata files and their type (DIMAP, SAFE, txt file, ... ). Note that the image itself can
   also be part of the list if there are metadata embedded in the image.

2. Reading the metadata files. The purpose of this step is to parse each metadata file associated
   with the image file and supply it as a (in-memory) XML tree. This tree is given to a IMI that
   will look for needed information. The parsing can be done by different classes, so far we expect
   a plain XMLReader, a TextMetadataReader and a GDALMetadataReader. They can all derive from a 
   base class. Depending on the format:

   * XMLReader can be simply implemented using TinyXML
   * TextMetadataReader will try to parse 'key=value' pairs and format it in a XML tree.
   * GDALMetadataReader will use GDALDataset::GetMetadata() to extract 'key=value' pairs
     and format them into a XML tree. 

3. Parsing in IMI. This step consists in finding the relevant metadata in the different XML trees
   and mapping them into a KeywordList (map<string,string>) with the usual metadata keys (used 
   in geom files). At this step, we keep the metadata as strings, but we may also do specific
   conversions to check the numerical range. This parsing can be nicely written with generic 
   functions like ``add()`` used in ossimSentinel1Model.cpp. If the parsing returns successfully,
   the generated ImageKeywordlist is given to the input image metadata dictionary.

4. Instanciation of a Transform. I propose to separate the classes used to store and access 
   the product metadata, and the classes used to represent a transform associated with a sensor
   model. The truth is that among all the sensor models currently handled by Ossim, we mostly
   use RPC based models. There are few physical sensor models, but we could implement them with
   a generic "PushBroomSensorModel". Maybe complex physical models will actually deserve a separate
   implementation. Regarding SAR sensors, we now tend to rely on SarSensorModel which is generic.
   This separation would also be consistent if we want to handle both physical and RPC models associated
   with a given sensor (no need to clone the metadata class). An other good point is that pipelines
   that don't do any geometry or projection stuff will not have to instanciate and configure a sensor
   transform that they won't use anyway. The SensorTransform will be initialized
   from the ImageKeywordList obtained in step 3.

The following diagram sums up the different steps.

  .. image:: workflow_metadata.png

In the case of a single image file with a geom, the steps 1, 2 and 3 are not needed, the geom is
directly injected into the ImageKeywordlist.

In a nutshell, the IMI classes will be in charge of identifying the correct sensor and parsing all the
relevant metadata. The SensorTransform classes will operate various geometric transforms, configured
from an ImageKeywordList.

The role of IMI classes can also be extended, for instance give the list of metadata keys that carry
per-band values. A concatenate file will then be able to gather these metadata together.

Note from RKH: use RapidXML instead of TinyXML.

Refactoring of sensor models
----------------------------

The refactoring of OssimPlugins can be done as follows:

* Move the code related to metadata parsing into the corresponding IMI. Basically, with the
  proposed workflow, each IMI needs to implement:

  * a ``vector<MDFile> GetMetadataFiles( string input_path )`` function that returns paths to 
    candidate metadata files to check, and the associated type.
  * a ``bool Parse(void)`` function that will try to identify and parse a given sensor.
  
  The other functions to import/export to a GEOM file can be generic as a start. 

* Move the code related to geometric transforms into several generic SensorTransforms. For now we can
  expect:

  * a RPCSensorTransform (maybe based on ``GDALRPCTransform()``)
  * a SarSensorTransform
  * a GeometricSarSensorTransform ? (for deprecated SAR models)
  * a PushBroomSensorTransform ? (for Spot5)
  * a MatrixSensorTransform ? (for airborne sensors)

  For geometric transform, all the structures like ossimDpt, ossimGpt should be replaced with ITK classes.
  Ideally, the new SensorTransform could derive from otb::SensorModelBase, but the current classes
  SensorModelBase, ForwardSensorModel and InverseSensorModel are not really usefull. The difference between
  forward and inverse transform could very well be implemented with a template specialization on
  SensorModelBase. I propose to remove ForwardSensorModel and InverseSensorModel, refactor SensorModelBase, 
  and derive new SensorTransforms from SensorModelBase.
  
  Like with ossimSensorModel, we can implement tuning parameters in otb::SensorModelBase to reproduce
  the ossimAdjustableParameterInterface. The adjustment parameters are often used to configure a
  residual affine transform that is composed with the geometric model. 

Dispatch of OTBOssimPlugins
---------------------------

The following actions can be planned:

* gdal/ossimOgcWktTranslator: was used to convert WKT and OSSIM keywordlist. Since the map projections
  are read by GDAL and not by OSSIM, I think we can remove this class.
* ossim/ossimXXXModel:

  * ossimSarSensorModel: to be ported into otb::SarSensorTransform (in OTBTransform)
  * ossimGeometricSarSensorModel: only needed if we want to keep old SAR models (for backward 
    compatibility)
  * other models: the metadata parsing will be ported into specifics IMI in OTBMetadata

* ossim/otb/\*:

  * We should remove as many files as possible
  * Maybe the date-time classes can be kept, because it is difficult to find equivalent solutions
    in other libs (see Boost::DateTime and also QDateTime in QtCore)
  * The classes related to Ephemeris, Coordinates, and other frames should be removed. Frames can
    be defined by GDAL SRS.

Dispatch of OTBOSSIMAdapters
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

Actions: not sure this class is still usefull, a simple Convert/Quicklook/RigidTransformResample
would to the same thing. IMO -> to be removed.

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
