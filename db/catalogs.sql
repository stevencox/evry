CREATE SCHEMA "public";

CREATE SEQUENCE "public".cube_cub_id_seq START WITH 1;

CREATE SEQUENCE "public".environment_env_id_seq START WITH 1;

CREATE SEQUENCE "public".ephemeris_eph_id_seq START WITH 1;

CREATE SEQUENCE "public".filename_fn_id_seq START WITH 1;

CREATE SEQUENCE "public".image_img_id_seq START WITH 1;

CREATE SEQUENCE "public".ligthcurve_lcv_id_seq START WITH 1;

CREATE SEQUENCE "public".referencecat_ref_id_seq START WITH 1;

CREATE SEQUENCE "public".srccat_src_id_seq START WITH 1;

CREATE SEQUENCE "public".srccat_src_imgid_seq START WITH 1;

CREATE SEQUENCE "public".statistics_sta_id_seq START WITH 1;

CREATE TABLE "public".ccds ( 
	ccd_id               smallint  NOT NULL,
	ccd_detid            varchar(30)  ,
	ccd_usbhubnum        varchar(1)  ,
	ccd_usbhubcon        varchar(2)  ,
	ccd_pwrblknum        varchar(1)  ,
	ccd_pwrblkcon        varchar(2)  ,
	ccd_imagew           smallint  ,
	ccd_imageh           smallint  ,
	ccd_ccdpxszx         real  ,
	ccd_ccdpxszy         real  ,
	ccd_instrume         varchar(30)  ,
	CONSTRAINT pk_ccd_id PRIMARY KEY ( ccd_id )
 );

COMMENT ON COLUMN "public".ccds.ccd_id IS 'Primary key.';

COMMENT ON COLUMN "public".ccds.ccd_detid IS 'CCD camera serial number.';

COMMENT ON COLUMN "public".ccds.ccd_usbhubnum IS 'Number of the USB hub where the CCD camera is connected.';

COMMENT ON COLUMN "public".ccds.ccd_usbhubcon IS 'Number of the USB connector for a given USB hub where the CCD camera is connected.';

COMMENT ON COLUMN "public".ccds.ccd_pwrblknum IS 'Number of the power distribution block where the CCD camera is connected.';

COMMENT ON COLUMN "public".ccds.ccd_pwrblkcon IS 'Number of the power line of a given distribution block where the CCD camera is connected.';

COMMENT ON COLUMN "public".ccds.ccd_imagew IS 'Image CCD width along X axis.';

COMMENT ON COLUMN "public".ccds.ccd_imageh IS 'Image CCD width along Y axis.';

COMMENT ON COLUMN "public".ccds.ccd_ccdpxszx IS 'Pixel width in microns (after binning).';

COMMENT ON COLUMN "public".ccds.ccd_ccdpxszy IS 'Pixel height in microns (after binning).';

COMMENT ON COLUMN "public".ccds.ccd_instrume IS 'Name of CCD camera.';

CREATE TABLE "public".environment ( 
	env_id               bigserial  NOT NULL,
	env_domestatus       varchar(30)  ,
	env_winddir          smallint  ,
	env_windsped         real  ,
	env_outrelhu         real  ,
	env_outdewpt         real  ,
	env_indtemp          real  ,
	env_inrelhu          real  ,
	env_indewpt          real  ,
	env_inmtemp          real  ,
	env_inmrehu          real  ,
	env_rain             varchar(1)  ,
	env_cloudnss         real  ,
	env_skybrgth         real  ,
	CONSTRAINT pk_env_id PRIMARY KEY ( env_id )
 );

COMMENT ON COLUMN "public".environment.env_id IS 'Primary key.';

COMMENT ON COLUMN "public".environment.env_domestatus IS 'Dome status.';

COMMENT ON COLUMN "public".environment.env_winddir IS 'Wind direction (deg)';

COMMENT ON COLUMN "public".environment.env_windsped IS 'Wind speed (m/s).';

COMMENT ON COLUMN "public".environment.env_outrelhu IS 'Outside relative humidity.';

COMMENT ON COLUMN "public".environment.env_outdewpt IS 'Outside dew point.';

COMMENT ON COLUMN "public".environment.env_indtemp IS 'Inside dome temperature.';

COMMENT ON COLUMN "public".environment.env_inrelhu IS 'Inside dome relative humidity.';

COMMENT ON COLUMN "public".environment.env_indewpt IS 'Inside dome dew point.';

COMMENT ON COLUMN "public".environment.env_inmtemp IS 'Inside mushroom temperature.';

COMMENT ON COLUMN "public".environment.env_inmrehu IS 'Inside mushroom relative humidity.';

COMMENT ON COLUMN "public".environment.env_rain IS 'Rain (0/1)';

COMMENT ON COLUMN "public".environment.env_cloudnss IS 'Cloudiness (sky temp Ð ambient temp)';

COMMENT ON COLUMN "public".environment.env_skybrgth IS 'Sky brightness (magáarcsec^-2)';

CREATE TABLE "public".ephemeris ( 
	eph_id               bigserial  NOT NULL,
	eph_moonaz           real  ,
	eph_moonalt          real  ,
	eph_moonang          real  ,
	eph_moonphas         real  ,
	eph_sunaz            real  ,
	eph_sunalt           real  ,
	eph_sunang           real  ,
	CONSTRAINT pk_eph_id PRIMARY KEY ( eph_id )
 );

COMMENT ON COLUMN "public".ephemeris.eph_id IS 'Primary key.';

COMMENT ON COLUMN "public".ephemeris.eph_moonaz IS 'Moon azimuth.';

COMMENT ON COLUMN "public".ephemeris.eph_moonalt IS ' Moon altitude.';

COMMENT ON COLUMN "public".ephemeris.eph_moonang IS 'Elongation between Moon and center of CCD (requires A.net solution).';

COMMENT ON COLUMN "public".ephemeris.eph_moonphas IS 'Moon phase (%)';

COMMENT ON COLUMN "public".ephemeris.eph_sunaz IS 'Sun azimuth.';

COMMENT ON COLUMN "public".ephemeris.eph_sunalt IS 'Sun altitude.';

COMMENT ON COLUMN "public".ephemeris.eph_sunang IS 'Elongation between Sun and center of CCD.';

CREATE TABLE "public".evrproject ( 
	evr_id               smallint  NOT NULL,
	evr_prjdesc          varchar(255)  ,
	evr_prjpi            varchar(70)  ,
	evr_prjobser         varchar(70)  ,
	CONSTRAINT pk_evr_id PRIMARY KEY ( evr_id )
 );

COMMENT ON COLUMN "public".evrproject.evr_id IS 'Primary key (Evrproject ID)';

COMMENT ON COLUMN "public".evrproject.evr_prjdesc IS 'Project description.';

COMMENT ON COLUMN "public".evrproject.evr_prjpi IS 'Project PI';

COMMENT ON COLUMN "public".evrproject.evr_prjobser IS 'Project observer.';

CREATE TABLE "public".filename ( 
	fn_id                bigserial  NOT NULL,
	fn_pathname          varchar(90)  ,
	fn_origname          varchar(70)  ,
	CONSTRAINT pk_fn_id PRIMARY KEY ( fn_id )
 );

COMMENT ON TABLE "public".filename IS 'Lists path and filename of the individual FITS images.
Sometimes these columns may be left empty because the image has only been 
stored temporally.';

COMMENT ON COLUMN "public".filename.fn_id IS 'Primary key';

COMMENT ON COLUMN "public".filename.fn_pathname IS 'Path  where image file name is (temporally sometimes) stored.';

COMMENT ON COLUMN "public".filename.fn_origname IS 'Filename of the individual image which is (sometimes temporally) stored.';

CREATE TABLE "public".filters ( 
	fil_id               smallint  NOT NULL,
	fil_filter           varchar(30)  ,
	CONSTRAINT pk_fil_id PRIMARY KEY ( fil_id )
 );

COMMENT ON TABLE "public".filters IS 'Filters';

COMMENT ON COLUMN "public".filters.fil_id IS 'Primary key';

COMMENT ON COLUMN "public".filters.fil_filter IS 'Filter name';

CREATE TABLE "public".imgtype ( 
	imt_id               varchar(1)  NOT NULL,
	imt_imgtyp           varchar(50)  ,
	CONSTRAINT pk_imt_id PRIMARY KEY ( imt_id )
 );

COMMENT ON COLUMN "public".imgtype.imt_id IS 'Primary key';

CREATE TABLE "public".ligthcurve ( 
	lcv_id               bigserial  NOT NULL,
	lcv_epoch            timestamp  NOT NULL,
	lcv_object           varchar(17)  ,
	lcv_ra               float8  ,
	lcv_dec              float8  ,
	lcv_radec            spoint  ,
	lcv_mag              float8  ,
	lcv_magerr           float8  ,
	CONSTRAINT pk_lcv_id_epoch PRIMARY KEY ( lcv_id, lcv_epoch )
 );

COMMENT ON TABLE "public".ligthcurve IS 'To be populated with a PL/SQL procedure in a daily basis';

COMMENT ON COLUMN "public".ligthcurve.lcv_id IS 'SEXtractor running object number of the sextractor reference catalog.';

COMMENT ON COLUMN "public".ligthcurve.lcv_epoch IS 'Epoch of lightcurve source mesurement.';

COMMENT ON COLUMN "public".ligthcurve.lcv_object IS 'Source identificator from (RA,DEC): JHHMMSSSS+DDMMSSS';

COMMENT ON COLUMN "public".ligthcurve.lcv_ra IS 'RA(J2000) of the source in the SEXtractor reference catalog.';

COMMENT ON COLUMN "public".ligthcurve.lcv_dec IS 'DEC(J2000) of the source in the SEXtractor reference catalog.';

COMMENT ON COLUMN "public".ligthcurve.lcv_radec IS '(RAJ2000,DECJ2000) spherical data type for the position of the source in the SEXtractor reference catalog.';

COMMENT ON COLUMN "public".ligthcurve.lcv_mag IS 'Magnitude of the source for the measurement at the given epoch.';

COMMENT ON COLUMN "public".ligthcurve.lcv_magerr IS 'Magnitude error of the source for the measurement at the given epoch.';

CREATE TABLE "public".referencecat ( 
	ref_id               bigserial  NOT NULL,
	ref_object           varchar(17)  ,
	ref_alphawin_j2000   float8  ,
	ref_deltawin_j2000   float8  ,
	CONSTRAINT pk_ref_id PRIMARY KEY ( ref_id )
 );

COMMENT ON TABLE "public".referencecat IS 'SEXtractor photometry of all-sky source taken with Evryscope used as a reference catalog for future observations.';

COMMENT ON COLUMN "public".referencecat.ref_id IS 'SEXtractor running reference object number.';

COMMENT ON COLUMN "public".referencecat.ref_object IS 'Source identificator from (RA,DEC): JHHMMSSSS+DDMMSSS';

COMMENT ON COLUMN "public".referencecat.ref_alphawin_j2000 IS 'Windowed right ascension (J2000).';

COMMENT ON COLUMN "public".referencecat.ref_deltawin_j2000 IS 'Windowed declination (J2000).';

CREATE TABLE "public"."statistics" ( 
	sta_id               bigserial  NOT NULL,
	sta_mean             real  ,
	sta_median           real  ,
	sta_stdev            real  ,
	sta_min              real  ,
	sta_mintx            smallint  ,
	sta_minty            smallint  ,
	sta_max              real  ,
	sta_maxtx            smallint  ,
	sta_maxty            smallint  ,
	CONSTRAINT pk_sta_id PRIMARY KEY ( sta_id )
 );

COMMENT ON COLUMN "public"."statistics".sta_id IS 'Primary key.';

COMMENT ON COLUMN "public"."statistics".sta_mean IS 'Mean of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_median IS 'Median of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_stdev IS 'Standard deviation of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_min IS 'Minimum pixel value of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_mintx IS 'Row of min pixel value of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_minty IS 'Column of min pixel value of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_max IS 'Maximum pixel value of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_maxtx IS 'Row of max pixel value of the whole image.';

COMMENT ON COLUMN "public"."statistics".sta_maxty IS 'Column of max pixel value of the whole image.';

CREATE TABLE "public".telescope ( 
	tel_id               smallint  NOT NULL,
	tel_telescop         varchar(30)  ,
	tel_origin           varchar(20)  ,
	tel_obslat           real  ,
	tel_obslon           real  ,
	tel_obsalt           real  ,
	CONSTRAINT pk_tel_id PRIMARY KEY ( tel_id )
 );

COMMENT ON COLUMN "public".telescope.tel_id IS 'Primary key.';

COMMENT ON COLUMN "public".telescope.tel_telescop IS 'Name of the telescope.';

COMMENT ON COLUMN "public".telescope.tel_origin IS 'Name of the site.';

COMMENT ON COLUMN "public".telescope.tel_obslat IS 'Site geographical latitude (deg).';

COMMENT ON COLUMN "public".telescope.tel_obslon IS 'Site geographical longitude (deg).';

COMMENT ON COLUMN "public".telescope.tel_obsalt IS 'Site geographical altitude HMSL (m).';

CREATE TABLE "public".image ( 
	img_id               bigserial  NOT NULL,
	img_typid            varchar(1)  NOT NULL,
	img_nameid           bigint  NOT NULL,
	img_ccdid            smallint  NOT NULL,
	img_telid            smallint  NOT NULL,
	img_filid            smallint  NOT NULL,
	img_staid            bigint  NOT NULL,
	img_envid            bigint  NOT NULL,
	img_ephid            bigint  ,
	img_evrid            smallint  NOT NULL,
	img_naxis1           smallint  NOT NULL,
	img_naxis2           smallint  NOT NULL,
	img_bitpix           smallint  NOT NULL,
	img_bscale           smallint DEFAULT 1 NOT NULL,
	img_bzero            smallint DEFAULT 0 NOT NULL,
	img_utc              timestamp  NOT NULL,
	img_obslst           time  ,
	img_obsdate          date  ,
	img_obstime          time  ,
	img_obsmjd           timestamp  ,
	img_obshmjd          timestamp  ,
	img_mountra          float8  ,
	img_mountdec         float8  ,
	img_mounthr          time  ,
	img_mountazi         float8  ,
	img_mountalt         float8  ,
	img_equinox          real DEFAULT 2000.0 NOT NULL,
	img_ra               float8  ,
	img_dec              float8  ,
	img_radec            spoint  ,
	img_ra2k             float8  ,
	img_dec2k            float8  ,
	img_radec2k          spoint  ,
	img_longpole         real DEFAULT 180.0 ,
	img_latpole          real DEFAULT 0.0 ,
	img_wcsaxes          smallint DEFAULT 2 ,
	img_ctype1           varchar(20)  ,
	img_ctype2           varchar(20)  ,
	img_crval1           float8  ,
	img_crval2           float8  ,
	img_crpix1           float8  ,
	img_crpix2           float8  ,
	img_cunit1           varchar(20)  ,
	img_cunit2           varchar(20)  ,
	img_cd1_1            float8  ,
	img_cd1_2            float8  ,
	img_cd2_1            float8  ,
	img_cd2_2            float8  ,
	img_pv1_1            float8  ,
	img_pv1_4            float8  ,
	img_pv1_5            float8  ,
	img_pv1_6            float8  ,
	img_pv1_7            float8  ,
	img_pv1_8            float8  ,
	img_pv1_9            float8  ,
	img_pv1_10           float8  ,
	img_pv1_12           float8  ,
	img_pv1_13           float8  ,
	img_pv1_14           float8  ,
	img_pv1_15           float8  ,
	img_pv1_16           float8  ,
	img_pv1_17           float8  ,
	img_pv1_18           float8  ,
	img_pv1_19           float8  ,
	img_pv1_20           float8  ,
	img_pv1_21           float8  ,
	img_pv1_22           float8  ,
	img_pv2_1            float8  ,
	img_pv2_4            float8  ,
	img_pv2_5            float8  ,
	img_pv2_6            float8  ,
	img_pv2_7            float8  ,
	img_pv2_8            float8  ,
	img_pv2_9            float8  ,
	img_pv2_10           float8  ,
	img_pv2_12           float8  ,
	img_pv2_13           float8  ,
	img_pv2_14           float8  ,
	img_pv2_15           float8  ,
	img_pv2_16           float8  ,
	img_pv2_17           float8  ,
	img_pv2_18           float8  ,
	img_pv2_19           float8  ,
	img_pv2_20           float8  ,
	img_pv2_21           float8  ,
	img_pv2_22           float8  ,
	img_pixscale         real  ,
	img_airmass          real  ,
	img_exptime          real  ,
	img_settemp          real  ,
	img_ccdcpwr          real  ,
	img_ccdtemp          real  ,
	img_ccdxbin          smallint DEFAULT 1 ,
	img_ccdybin          smallint DEFAULT 1 ,
	img_ccdroix          smallint  ,
	img_ccdroiy          smallint  ,
	img_ccdroisx         smallint  ,
	img_ccdroisy         smallint  ,
	img_ccdspeed         varchar(30)  ,
	img_ccdrbifl         varchar(30)  ,
	img_focuspos         real  ,
	img_defocus          real  ,
	img_trackspd         real  ,
	img_date             timestamp  ,
	img_checksum         varchar(40)  ,
	CONSTRAINT pk_img_id PRIMARY KEY ( img_id ),
	CONSTRAINT fk_img_ccdid FOREIGN KEY ( img_ccdid ) REFERENCES "public".ccds( ccd_id )    ,
	CONSTRAINT fk_img_nameid FOREIGN KEY ( img_nameid ) REFERENCES "public".filename( fn_id )    ,
	CONSTRAINT fk_img_typid FOREIGN KEY ( img_typid ) REFERENCES "public".imgtype( imt_id )    ,
	CONSTRAINT fk_img_telid FOREIGN KEY ( img_telid ) REFERENCES "public".telescope( tel_id )    ,
	CONSTRAINT fk_img_filid FOREIGN KEY ( img_filid ) REFERENCES "public".filters( fil_id )    ,
	CONSTRAINT fk_img_staid FOREIGN KEY ( img_staid ) REFERENCES "public"."statistics"( sta_id )    ,
	CONSTRAINT fk_img_envid FOREIGN KEY ( img_envid ) REFERENCES "public".environment( env_id )    ,
	CONSTRAINT fk_img_ephid FOREIGN KEY ( img_ephid ) REFERENCES "public".ephemeris( eph_id )    ,
	CONSTRAINT fk_img_evrid FOREIGN KEY ( img_evrid ) REFERENCES "public".evrproject( evr_id )    
 );

COMMENT ON TABLE "public".image IS 'Lists metadata of non-compressed individual FITS images.
For saving storage reasons these FITS files are not stored 
on disk uncompressed and individually, but ina MEF (cube) fashion 
and fpack compressed (see cube table).';

COMMENT ON COLUMN "public".image.img_id IS 'Primary key';

COMMENT ON COLUMN "public".image.img_typid IS 'Foreign key for imgtype.img_typeid to indicate the exposure type.
b:bias;k:dark;f:focus;s:skyflat;o:object/science;t:test;p:pointing';

COMMENT ON COLUMN "public".image.img_nameid IS 'Foreign key of name.name_id for storing path and name of the image file.';

COMMENT ON COLUMN "public".image.img_ccdid IS 'Foreign key for ccd.ccd_id to indicate those static atributes of the CCDs';

COMMENT ON COLUMN "public".image.img_telid IS 'Foreign key for telescope.tel_id';

COMMENT ON COLUMN "public".image.img_filid IS 'Foreign key for filter.filt_id';

COMMENT ON COLUMN "public".image.img_staid IS 'Foreign key for statistics.sta_id';

COMMENT ON COLUMN "public".image.img_envid IS 'Foreign key for environment.env_id';

COMMENT ON COLUMN "public".image.img_ephid IS 'Foreign key for ephemeris.eph_id';

COMMENT ON COLUMN "public".image.img_evrid IS 'Foreign key for evrproject.evrprj_id';

COMMENT ON COLUMN "public".image.img_naxis1 IS 'image naxis1';

COMMENT ON COLUMN "public".image.img_naxis2 IS 'image naxis2';

COMMENT ON COLUMN "public".image.img_bitpix IS 'image bitpix';

COMMENT ON COLUMN "public".image.img_bscale IS 'image bscale';

COMMENT ON COLUMN "public".image.img_bzero IS 'image bzero';

COMMENT ON COLUMN "public".image.img_utc IS 'timestamp of obsevation in UTC';

COMMENT ON COLUMN "public".image.img_obslst IS 'time for Local Sidereal Time';

COMMENT ON COLUMN "public".image.img_obsdate IS 'image observation date in UTC';

COMMENT ON COLUMN "public".image.img_obstime IS 'image observation time in UTC';

COMMENT ON COLUMN "public".image.img_obsmjd IS 'image observation timestamp in modified Julian date';

COMMENT ON COLUMN "public".image.img_obshmjd IS 'image observation timestamp in heliocentric modified Julian date';

COMMENT ON COLUMN "public".image.img_mountra IS 'Pointed mount RA (J2000)';

COMMENT ON COLUMN "public".image.img_mountdec IS 'Pointed mount DEC (J2000)';

COMMENT ON COLUMN "public".image.img_mounthr IS 'Pointed mount Hour angle (0-24h)';

COMMENT ON COLUMN "public".image.img_mountazi IS 'Pointed mount Azimuth';

COMMENT ON COLUMN "public".image.img_mountalt IS 'Pointed mount elevation';

COMMENT ON COLUMN "public".image.img_equinox IS '(img_ra, img_dec) coordinates equinox';

COMMENT ON COLUMN "public".image.img_ra IS 'RA of central CCD pixel as per A.net astrometric reduction';

COMMENT ON COLUMN "public".image.img_dec IS 'DEC of central CCD pixel as per A.net astrometric reduction';

COMMENT ON COLUMN "public".image.img_radec IS '(RA,DEC) spherical data type of central CCD pixel as A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_ra2k IS 'RA(J2000) of central CCD pixel as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_dec2k IS 'DEC(J2000) of central CCD pixel as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_radec2k IS '(RAJ2000,DECJ2000) of central CCD pixel as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_longpole IS 'Longitude of the pole of the coordinate system.';

COMMENT ON COLUMN "public".image.img_latpole IS 'Latitude of the pole of the coordinate system.';

COMMENT ON COLUMN "public".image.img_wcsaxes IS 'Number of WCS axes.';

COMMENT ON COLUMN "public".image.img_ctype1 IS 'WCS Type of the horizontal coordinate, including coordinate and projection.';

COMMENT ON COLUMN "public".image.img_ctype2 IS 'WCS Type of the vertical coordinate, including coordinate and projection.';

COMMENT ON COLUMN "public".image.img_crval1 IS 'RA  of reference point (RA at tangential point)  as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_crval2 IS 'DEC of reference point (DEC at tangential point) as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_crpix1 IS 'X reference pixel (X pixel value at tangential point)  as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_crpix2 IS 'Y reference pixel (Y pixel value at tangential point) as per A.net astrometric reduction.';

COMMENT ON COLUMN "public".image.img_cunit1 IS 'Units of horizontal spherical coordinates.';

COMMENT ON COLUMN "public".image.img_cunit2 IS 'Units of vertical spherical coordinates.';

COMMENT ON COLUMN "public".image.img_cd1_1 IS 'WCS transformation matrix: partial of first axis coordinate w.r.t. X.';

COMMENT ON COLUMN "public".image.img_cd1_2 IS 'WCS transformation matrix: partial of first axis coordinate w.r.t. Y.';

COMMENT ON COLUMN "public".image.img_cd2_1 IS 'WCS transformation matrix: partial of second axis coordinate w.r.t. X.';

COMMENT ON COLUMN "public".image.img_cd2_2 IS 'WCS transformation matrix: partial of second axis coordinate w.r.t. Y.';

COMMENT ON COLUMN "public".image.img_pixscale IS 'Pixel scale (arcsec/pix)';

COMMENT ON COLUMN "public".image.img_airmass IS 'Airmass of central pixel of the CCD as per A.net astrometric reduction';

COMMENT ON COLUMN "public".image.img_exptime IS 'Exposure time';

COMMENT ON COLUMN "public".image.img_settemp IS 'CCD set point temp (C)';

COMMENT ON COLUMN "public".image.img_ccdcpwr IS 'CCD cooler power percentage';

COMMENT ON COLUMN "public".image.img_ccdtemp IS 'Actual CCD temp (C)';

COMMENT ON COLUMN "public".image.img_ccdxbin IS 'Column binning';

COMMENT ON COLUMN "public".image.img_ccdybin IS 'Row binning';

COMMENT ON COLUMN "public".image.img_ccdroix IS 'Central X coordinate of Region Of Interest (ROI)';

COMMENT ON COLUMN "public".image.img_ccdroiy IS 'Central Y coordinate of Region Of Interest (ROI)';

COMMENT ON COLUMN "public".image.img_ccdroisx IS 'Region Of Interest (ROI) size along X';

COMMENT ON COLUMN "public".image.img_ccdroisy IS 'Region Of Interest (ROI) size along Y';

COMMENT ON COLUMN "public".image.img_ccdspeed IS 'CCD readout speed (Low/High)';

COMMENT ON COLUMN "public".image.img_ccdrbifl IS 'CCD RBI flood (On/Off)';

COMMENT ON COLUMN "public".image.img_focuspos IS 'Focus position';

COMMENT ON COLUMN "public".image.img_defocus IS 'Defocus on purpose for some reason';

COMMENT ON COLUMN "public".image.img_trackspd IS 'Tracking speed';

COMMENT ON COLUMN "public".image.img_date IS 'Timestamp when file was written.';

COMMENT ON COLUMN "public".image.img_checksum IS 'File checksum hash (SHA-1).';

CREATE TABLE "public".sourcecat ( 
	src_imgid            bigserial  NOT NULL,
	src_id               serial  NOT NULL,
	src_flux_auto        real  ,
	src_fluxerr_auto     real  ,
	src_background       float8  ,
	src_flux_max         float8  ,
	src_xwin_image       real  ,
	src_ywin_image       real  ,
	src_alphawin_j2000   float8  ,
	src_deltawin_j2000   float8  ,
	src_elongation       real  ,
	src_fwhm_image       real  ,
	src_flags            varchar(3)  ,
	CONSTRAINT pk_src_imgid_id PRIMARY KEY ( src_imgid, src_id ),
	CONSTRAINT fk_src_imgid FOREIGN KEY ( src_imgid ) REFERENCES "public".image( img_id )    ,
	CONSTRAINT fk_src_id FOREIGN KEY ( src_id ) REFERENCES "public".referencecat( ref_id )    
 );

COMMENT ON TABLE "public".sourcecat IS 'SEXtractor photometry of each source on each individual FITS image.';

COMMENT ON COLUMN "public".sourcecat.src_imgid IS 'ID of individual FITS image: foreign key.';

COMMENT ON COLUMN "public".sourcecat.src_id IS 'SEXtractor running object number.';

COMMENT ON COLUMN "public".sourcecat.src_flux_auto IS 'Flux within a Kron-like elliptical aperture.';

COMMENT ON COLUMN "public".sourcecat.src_fluxerr_auto IS 'RMS error for AUTO flux.';

COMMENT ON COLUMN "public".sourcecat.src_background IS 'Background at centroid position.';

COMMENT ON COLUMN "public".sourcecat.src_flux_max IS 'Peak flux above background.';

COMMENT ON COLUMN "public".sourcecat.src_xwin_image IS 'Windowed position estimate along x.';

COMMENT ON COLUMN "public".sourcecat.src_ywin_image IS 'Windowed position estimate along y.';

COMMENT ON COLUMN "public".sourcecat.src_alphawin_j2000 IS 'Windowed right ascension (J2000).';

COMMENT ON COLUMN "public".sourcecat.src_deltawin_j2000 IS 'windowed declination (J2000).';

COMMENT ON COLUMN "public".sourcecat.src_elongation IS 'A_IMAGE/B_IMAGE';

COMMENT ON COLUMN "public".sourcecat.src_fwhm_image IS 'FWHM assuming a gaussian core.';

COMMENT ON COLUMN "public".sourcecat.src_flags IS 'Extraction flags.';

CREATE TABLE "public"."cube" ( 
	cub_id               bigserial  NOT NULL,
	cub_imgid            bigint  ,
	cub_ccdid            smallint  ,
	cub_extnumber        smallint  ,
	cub_extname          varchar(255)  ,
	cub_path             varchar(512)  ,
	cub_origname         varchar(255)  ,
	cub_compressed       bool  ,
	cub_numexts          smallint  ,
	cub_qfactor          smallint  ,
	cub_tile1            smallint  ,
	cub_tile2            smallint  ,
	cub_cmptype          varchar(25)  ,
	cub_date             timestamp  ,
	CONSTRAINT pk_cub_id PRIMARY KEY ( cub_id ),
	CONSTRAINT fk_cub_imgid FOREIGN KEY ( cub_imgid ) REFERENCES "public".image( img_id )    
 );

COMMENT ON TABLE "public"."cube" IS 'Lists compressed MEF cube files which are stored on disk, fpack-compressed.
Each cube contains CUB_NUMEXTS of extensions (images), which are foreign keyed by CUB_EXPID';

COMMENT ON COLUMN "public"."cube".cub_id IS 'primary key';

COMMENT ON COLUMN "public"."cube".cub_imgid IS 'Foreign key links to image.img_id';

COMMENT ON COLUMN "public"."cube".cub_ccdid IS 'CCD number: 0,...,26';

COMMENT ON COLUMN "public"."cube".cub_extnumber IS 'Extension number of the MEF (cube) file';

COMMENT ON COLUMN "public"."cube".cub_extname IS 'Name of the file of an individual extension in the MEF (cube) file.
cub_extname does not necesseraly to exist, since  it may be removed
once the cube is created.';

COMMENT ON COLUMN "public"."cube".cub_path IS 'Path where cubes are stored';

COMMENT ON COLUMN "public"."cube".cub_origname IS 'Filename of MEF (cube)';

COMMENT ON COLUMN "public"."cube".cub_compressed IS 'Is the cube compressed (True/False)';

COMMENT ON COLUMN "public"."cube".cub_numexts IS 'Number of extensions for each cube';

COMMENT ON COLUMN "public"."cube".cub_qfactor IS 'Value of compression factor q of fpack';

COMMENT ON COLUMN "public"."cube".cub_tile1 IS 'Number of pixels for tile dimension in x axis for fpack';

COMMENT ON COLUMN "public"."cube".cub_tile2 IS 'Number of pixels for tile dimension in y axis for fpack';

COMMENT ON COLUMN "public"."cube".cub_cmptype IS 'Compression algorithm used in fpack';

COMMENT ON COLUMN "public"."cube".cub_date IS 'Cube creation date';

CREATE OR REPLACE FUNCTION public.area(scircle)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_area$function$
CREATE OR REPLACE FUNCTION public.area(spoly)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_area$function$
CREATE OR REPLACE FUNCTION public.area(sbox)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_area$function$

CREATE OR REPLACE FUNCTION public.axes(strans)
 RETURNS character
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_type$function$

CREATE OR REPLACE FUNCTION public.center(scircle)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_center$function$
CREATE OR REPLACE FUNCTION public.center(sellipse)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_center$function$

CREATE OR REPLACE FUNCTION public.circum(scircle)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_circ$function$
CREATE OR REPLACE FUNCTION public.circum(spoly)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_circ$function$
CREATE OR REPLACE FUNCTION public.circum(sbox)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_circ$function$

CREATE OR REPLACE FUNCTION public.crossmatch(text, text, double precision)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/pg_sphere', $function$crossmatch$function$
CREATE OR REPLACE FUNCTION public.crossmatch(text, text, double precision, sbox)
 RETURNS SETOF record
 LANGUAGE c
 STABLE STRICT
AS '$libdir/pg_sphere', $function$crossmatch$function$

CREATE OR REPLACE FUNCTION public.dist(spoint, spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_distance$function$
CREATE OR REPLACE FUNCTION public.dist(spoint, scircle)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_point_distance_com$function$
CREATE OR REPLACE FUNCTION public.dist(scircle, spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_point_distance$function$
CREATE OR REPLACE FUNCTION public.dist(scircle, scircle)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_distance$function$

CREATE OR REPLACE FUNCTION public.g_sbox_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_sbox_compress$function$

CREATE OR REPLACE FUNCTION public.g_sbox_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_sbox_consistent$function$

CREATE OR REPLACE FUNCTION public.g_scircle_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_scircle_compress$function$

CREATE OR REPLACE FUNCTION public.g_scircle_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_scircle_consistent$function$

CREATE OR REPLACE FUNCTION public.g_sellipse_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_sellipse_compress$function$

CREATE OR REPLACE FUNCTION public.g_sellipse_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_sellipse_consistent$function$

CREATE OR REPLACE FUNCTION public.g_sline_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_sline_compress$function$

CREATE OR REPLACE FUNCTION public.g_sline_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_sline_consistent$function$

CREATE OR REPLACE FUNCTION public.g_spath_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spath_compress$function$

CREATE OR REPLACE FUNCTION public.g_spath_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spath_consistent$function$

CREATE OR REPLACE FUNCTION public.g_spherekey_decompress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spherekey_decompress$function$

CREATE OR REPLACE FUNCTION public.g_spherekey_penalty(internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 STRICT
AS '$libdir/pg_sphere', $function$g_spherekey_penalty$function$

CREATE OR REPLACE FUNCTION public.g_spherekey_picksplit(internal, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spherekey_picksplit$function$

CREATE OR REPLACE FUNCTION public.g_spherekey_same(spherekey, spherekey, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spherekey_same$function$

CREATE OR REPLACE FUNCTION public.g_spherekey_union(bytea, internal)
 RETURNS spherekey
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spherekey_union$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint2_compress$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint2_consistent$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_distance(internal, internal, integer, oid)
 RETURNS double precision
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint2_distance$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_penalty(internal, internal, internal)
 RETURNS internal
 LANGUAGE c
 STRICT
AS '$libdir/pg_sphere', $function$g_spoint2_penalty$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_picksplit(internal, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint2_picksplit$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_same(bytea, bytea, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint2_same$function$

CREATE OR REPLACE FUNCTION public.g_spoint2_union(bytea, internal)
 RETURNS spherekey
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint2_union$function$

CREATE OR REPLACE FUNCTION public.g_spoint_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint_compress$function$

CREATE OR REPLACE FUNCTION public.g_spoint_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoint_consistent$function$

CREATE OR REPLACE FUNCTION public.g_spoly_compress(internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoly_compress$function$

CREATE OR REPLACE FUNCTION public.g_spoly_consistent(internal, internal, integer, oid, internal)
 RETURNS internal
 LANGUAGE c
AS '$libdir/pg_sphere', $function$g_spoly_consistent$function$

CREATE OR REPLACE FUNCTION public.inc(sellipse)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_incl$function$

CREATE OR REPLACE FUNCTION public.lat(spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_lat$function$

CREATE OR REPLACE FUNCTION public.length(sline)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_length$function$
CREATE OR REPLACE FUNCTION public.length(spath)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_length$function$

CREATE OR REPLACE FUNCTION public.long(spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_long$function$

CREATE OR REPLACE FUNCTION public.lrad(sellipse)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_rad1$function$

CREATE OR REPLACE FUNCTION public.meridian(double precision)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_meridian$function$

CREATE OR REPLACE FUNCTION public.ne(sbox)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_ne$function$

CREATE OR REPLACE FUNCTION public.npoints(spoly)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_npts$function$
CREATE OR REPLACE FUNCTION public.npoints(spath)
 RETURNS integer
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_npts$function$

CREATE OR REPLACE FUNCTION public.nw(sbox)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_nw$function$

CREATE OR REPLACE FUNCTION public.phi(strans)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_phi$function$

CREATE OR REPLACE FUNCTION public.pointkey_area(pointkey)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$pointkey_area$function$

CREATE OR REPLACE FUNCTION public.pointkey_perimeter(pointkey)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$pointkey_perimeter$function$

CREATE OR REPLACE FUNCTION public.pointkey_volume(pointkey)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$pointkey_volume$function$

CREATE OR REPLACE FUNCTION public.psi(strans)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_psi$function$

CREATE OR REPLACE FUNCTION public.radius(scircle)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_radius$function$

CREATE OR REPLACE FUNCTION public.sbox(spoint, spoint)
 RETURNS sbox
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_in_from_points$function$

CREATE OR REPLACE FUNCTION public.sbox_cont_point(sbox, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_point$function$

CREATE OR REPLACE FUNCTION public.sbox_cont_point_com(spoint, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_point_com$function$

CREATE OR REPLACE FUNCTION public.sbox_cont_point_com_neg(spoint, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_point_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_cont_point_neg(sbox, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_point_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_box(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_box$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_box_com(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_box_com$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_box_com_neg(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_box_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_box_neg(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_box_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_circle(sbox, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_circle$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_circle_com(scircle, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_circle_com$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_circle_com_neg(scircle, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_circle_neg(sbox, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_circle_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_ellipse(sbox, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_ellipse$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_ellipse_com(sellipse, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_ellipse_com$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_ellipse_com_neg(sellipse, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_ellipse_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_ellipse_neg(sbox, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_line(sbox, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_line$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_line_com(sline, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_line_com$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_line_com_neg(sline, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_line_neg(sbox, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_line_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_path(sbox, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_path$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_path_com(spath, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_path_com$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_path_com_neg(spath, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_path_neg(sbox, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_path_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_poly(sbox, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_poly$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_poly_com(spoly, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_poly_com$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_poly_com_neg(spoly, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_poly_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_contains_poly_neg(sbox, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_cont_poly_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_equal(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_equal$function$

CREATE OR REPLACE FUNCTION public.sbox_equal_neg(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_equal_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_box(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_box$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_box_neg(sbox, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_box_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_circle(sbox, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_circle$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_circle_com(scircle, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_circle_com$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_circle_com_neg(scircle, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_circle_neg(sbox, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_circle_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_ellipse(sbox, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_ellipse$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_ellipse_com(sellipse, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_ellipse_com$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_ellipse_com_neg(sellipse, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_ellipse_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_ellipse_neg(sbox, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_line(sbox, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_line$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_line_com(sline, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_line_com$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_line_com_neg(sline, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_line_neg(sbox, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_line_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_path(sbox, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_path$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_path_com(spath, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_path_com$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_path_com_neg(spath, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_path_neg(sbox, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_path_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_poly(sbox, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_poly$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_poly_com(spoly, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_poly_com$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_poly_com_neg(spoly, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_poly_com_neg$function$

CREATE OR REPLACE FUNCTION public.sbox_overlap_poly_neg(sbox, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_overlap_poly_neg$function$

CREATE OR REPLACE FUNCTION public.scircle(spoint)
 RETURNS scircle
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_to_circle$function$
CREATE OR REPLACE FUNCTION public.scircle(sellipse)
 RETURNS scircle
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_circle$function$
CREATE OR REPLACE FUNCTION public.scircle(spoint, double precision)
 RETURNS scircle
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_by_center$function$

CREATE OR REPLACE FUNCTION public.scircle_contained_by_circle(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_in_circle$function$

CREATE OR REPLACE FUNCTION public.scircle_contained_by_circle_neg(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_in_circle_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_box(scircle, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_box$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_box_com(sbox, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_box_com$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_box_com_neg(sbox, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_box_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_box_neg(scircle, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_box_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_circle(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_in_circle_com$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_circle_neg(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_in_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_ellipse(scircle, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_ellipse$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_ellipse_com(sellipse, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_ellipse_com$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_ellipse_com_neg(sellipse, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_ellipse_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_ellipse_neg(scircle, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_line(scircle, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_line$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_line_com(sline, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_line_com$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_line_com_neg(sline, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_line_neg(scircle, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_line_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_path(scircle, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_path$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_path_com(spath, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_path_com$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_path_com_neg(spath, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_path_neg(scircle, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_path_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_polygon(scircle, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_poly$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_polygon_com(spoly, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_poly_com$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_polygon_com_neg(spoly, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_poly_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_contains_polygon_neg(scircle, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_cont_poly_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_equal(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_equal$function$

CREATE OR REPLACE FUNCTION public.scircle_equal_neg(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_equal_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_overlap(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_overlap$function$

CREATE OR REPLACE FUNCTION public.scircle_overlap_neg(scircle, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_overlap_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_overlap_path(scircle, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_overlap_path$function$

CREATE OR REPLACE FUNCTION public.scircle_overlap_path_com(spath, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_overlap_path_com$function$

CREATE OR REPLACE FUNCTION public.scircle_overlap_path_com_neg(spath, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_overlap_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.scircle_overlap_path_neg(scircle, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_overlap_path_neg$function$

CREATE OR REPLACE FUNCTION public.se(sbox)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_se$function$

CREATE OR REPLACE FUNCTION public.sellipse(spoint)
 RETURNS sellipse
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_ellipse$function$
CREATE OR REPLACE FUNCTION public.sellipse(scircle)
 RETURNS sellipse
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherecircle_ellipse$function$
CREATE OR REPLACE FUNCTION public.sellipse(spoint, double precision, double precision, double precision)
 RETURNS sellipse
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_infunc$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_box(sellipse, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_box$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_box_com(sbox, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_box_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_box_com_neg(sbox, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_box_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_box_neg(sellipse, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_box_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_circle(sellipse, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_circle$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_circle_com(scircle, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_circle_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_circle_com_neg(scircle, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_circle_neg(sellipse, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_circle_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_ellipse(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_ellipse$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_ellipse_com(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_ellipse_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_ellipse_com_neg(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_ellipse_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_ellipse_neg(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_line(sellipse, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_line$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_line_com(sline, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_line_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_line_com_neg(sline, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_line_neg(sellipse, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_line_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_path(sellipse, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_path$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_path_com(spath, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_path_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_path_com_neg(spath, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_path_neg(sellipse, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_path_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_point(sellipse, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_point$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_point_com(spoint, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_point_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_point_com_neg(spoint, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_point_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_point_neg(sellipse, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_point_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_polygon(sellipse, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_poly$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_polygon_com(spoly, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_poly_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_polygon_com_neg(spoly, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_poly_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_contains_polygon_neg(sellipse, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_cont_poly_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_equal(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_equal$function$

CREATE OR REPLACE FUNCTION public.sellipse_equal_neg(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_equal_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_circle(sellipse, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_circle$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_circle_com(scircle, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_circle_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_circle_com_neg(scircle, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_circle_neg(sellipse, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_circle_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_ellipse(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_ellipse$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_ellipse_neg(sellipse, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_line(sellipse, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_line$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_line_com(sline, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_line_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_line_com_neg(sline, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_line_neg(sellipse, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_line_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_path(sellipse, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_path$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_path_com(spath, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_path_com$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_path_com_neg(spath, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.sellipse_overlap_path_neg(sellipse, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_overlap_path_neg$function$

CREATE OR REPLACE FUNCTION public.sl_beg(sline)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_begin$function$

CREATE OR REPLACE FUNCTION public.sl_end(sline)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_end$function$

CREATE OR REPLACE FUNCTION public.sline(spoint)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_from_point$function$
CREATE OR REPLACE FUNCTION public.sline(spoint, spoint)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_from_points$function$
CREATE OR REPLACE FUNCTION public.sline(strans, double precision)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_from_trans$function$

CREATE OR REPLACE FUNCTION public.sline_contains_point(sline, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_cont_point$function$

CREATE OR REPLACE FUNCTION public.sline_contains_point_com(spoint, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_cont_point_com$function$

CREATE OR REPLACE FUNCTION public.sline_contains_point_com_neg(spoint, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_cont_point_com_neg$function$

CREATE OR REPLACE FUNCTION public.sline_contains_point_neg(sline, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_cont_point_neg$function$

CREATE OR REPLACE FUNCTION public.sline_crosses(sline, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_crosses$function$

CREATE OR REPLACE FUNCTION public.sline_crosses_neg(sline, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_crosses_neg$function$

CREATE OR REPLACE FUNCTION public.sline_equal(sline, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_equal$function$

CREATE OR REPLACE FUNCTION public.sline_equal_neg(sline, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_equal_neg$function$

CREATE OR REPLACE FUNCTION public.sline_overlap(sline, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_overlap$function$

CREATE OR REPLACE FUNCTION public.sline_overlap_circle(sline, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_overlap_circle$function$

CREATE OR REPLACE FUNCTION public.sline_overlap_circle_com(scircle, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_overlap_circle_com$function$

CREATE OR REPLACE FUNCTION public.sline_overlap_circle_com_neg(scircle, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_overlap_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.sline_overlap_circle_neg(sline, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_overlap_circle_neg$function$

CREATE OR REPLACE FUNCTION public.sline_overlap_neg(sline, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_overlap_neg$function$

CREATE OR REPLACE FUNCTION public.spath_add_point_aggr(spath, spoint)
 RETURNS spath
 LANGUAGE c
 IMMUTABLE
AS '$libdir/pg_sphere', $function$spherepath_add_point$function$

CREATE OR REPLACE FUNCTION public.spath_add_points_fin_aggr(spath)
 RETURNS spath
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_add_points_finalize$function$

CREATE OR REPLACE FUNCTION public.spath_contains_point(spath, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_cont_point$function$

CREATE OR REPLACE FUNCTION public.spath_contains_point_com(spoint, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_cont_point_com$function$

CREATE OR REPLACE FUNCTION public.spath_contains_point_com_neg(spoint, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_cont_point_com_neg$function$

CREATE OR REPLACE FUNCTION public.spath_contains_point_neg(spath, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_cont_point_neg$function$

CREATE OR REPLACE FUNCTION public.spath_equal(spath, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_equal$function$

CREATE OR REPLACE FUNCTION public.spath_equal_neg(spath, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_equal_neg$function$

CREATE OR REPLACE FUNCTION public.spath_overlap_line(spath, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_overlap_line$function$

CREATE OR REPLACE FUNCTION public.spath_overlap_line_com(sline, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_overlap_line_com$function$

CREATE OR REPLACE FUNCTION public.spath_overlap_line_com_neg(sline, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_overlap_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.spath_overlap_line_neg(spath, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_overlap_line_neg$function$

CREATE OR REPLACE FUNCTION public.spath_overlap_path(spath, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_overlap_path$function$

CREATE OR REPLACE FUNCTION public.spath_overlap_path_neg(spath, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_overlap_path_neg$function$

CREATE OR REPLACE FUNCTION public.spoint(double precision, double precision)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_from_long_lat$function$
CREATE OR REPLACE FUNCTION public.spoint(spath, integer)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_get_point$function$
CREATE OR REPLACE FUNCTION public.spoint(spath, double precision)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_point$function$

CREATE OR REPLACE FUNCTION public.spoint_contained_by_circle(spoint, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_in_circle$function$

CREATE OR REPLACE FUNCTION public.spoint_contained_by_circle_com(scircle, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_in_circle_com$function$

CREATE OR REPLACE FUNCTION public.spoint_contained_by_circle_com_neg(scircle, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_in_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoint_contained_by_circle_neg(spoint, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_in_circle_neg$function$

CREATE OR REPLACE FUNCTION public.spoint_equal(spoint, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_equal$function$

CREATE OR REPLACE FUNCTION public.spoint_equal_neg(spoint, spoint)
 RETURNS boolean
 LANGUAGE sql
 IMMUTABLE STRICT
AS $function$SELECT NOT spoint_equal($1,$2);$function$

CREATE OR REPLACE FUNCTION public.spoly_add_point_aggr(spoly, spoint)
 RETURNS spoly
 LANGUAGE c
 IMMUTABLE
AS '$libdir/pg_sphere', $function$spherepoly_add_point$function$

CREATE OR REPLACE FUNCTION public.spoly_add_points_fin_aggr(spoly)
 RETURNS spoly
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_add_points_finalize$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_box(spoly, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_box$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_box_com(sbox, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_box_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_box_com_neg(sbox, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_box_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_box_neg(spoly, sbox)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_box_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_circle(spoly, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_circle$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_circle_com(scircle, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_circle_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_circle_com_neg(scircle, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_circle_neg(spoly, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_circle_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_ellipse(spoly, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_ellipse$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_ellipse_com(sellipse, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_ellipse_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_ellipse_com_neg(sellipse, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_ellipse_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_ellipse_neg(spoly, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_line(spoly, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_line$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_line_com(sline, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_line_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_line_com_neg(sline, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_line_neg(spoly, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_line_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_path(spoly, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_path$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_path_com(spath, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_path_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_path_com_neg(spath, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_path_neg(spoly, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_path_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_point(spoly, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_point$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_point_com(spoint, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_point_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_point_com_neg(spoint, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_point_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_point_neg(spoly, spoint)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_point_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_polygon(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_poly$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_polygon_com(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_poly_com$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_polygon_com_neg(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_poly_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_contains_polygon_neg(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_cont_poly_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_equal(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_equal$function$

CREATE OR REPLACE FUNCTION public.spoly_not_equal(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_equal_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_circle(spoly, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_circle$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_circle_com(scircle, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_circle_com$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_circle_com_neg(scircle, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_circle_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_circle_neg(spoly, scircle)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_circle_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_ellipse(spoly, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_ellipse$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_ellipse_com(sellipse, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_ellipse_com$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_ellipse_com_neg(sellipse, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_ellipse_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_ellipse_neg(spoly, sellipse)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_ellipse_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_line(spoly, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_line$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_line_com(sline, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_line_com$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_line_com_neg(sline, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_line_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_line_neg(spoly, sline)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_line_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_path(spoly, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_path$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_path_com(spath, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_path_com$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_path_com_neg(spath, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_path_com_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_path_neg(spoly, spath)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_path_neg$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_polygon(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_poly$function$

CREATE OR REPLACE FUNCTION public.spoly_overlap_polygon_neg(spoly, spoly)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoly_overlap_poly_neg$function$

CREATE OR REPLACE FUNCTION public.srad(sellipse)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_rad2$function$

CREATE OR REPLACE FUNCTION public.strans(double precision, double precision, double precision)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_from_float8$function$
CREATE OR REPLACE FUNCTION public.strans(double precision, double precision, double precision, cstring)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_from_float8_and_type$function$
CREATE OR REPLACE FUNCTION public.strans(strans)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans$function$
CREATE OR REPLACE FUNCTION public.strans(sline)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_from_line$function$
CREATE OR REPLACE FUNCTION public.strans(sellipse)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereellipse_trans$function$

CREATE OR REPLACE FUNCTION public.strans_circle(scircle, strans)
 RETURNS scircle
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_circle$function$

CREATE OR REPLACE FUNCTION public.strans_circle_inverse(scircle, strans)
 RETURNS scircle
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_circle_inverse$function$

CREATE OR REPLACE FUNCTION public.strans_ellipse(sellipse, strans)
 RETURNS sellipse
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_ellipse$function$

CREATE OR REPLACE FUNCTION public.strans_ellipse_inverse(sellipse, strans)
 RETURNS sellipse
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_ellipse_inv$function$

CREATE OR REPLACE FUNCTION public.strans_equal(strans, strans)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_equal$function$

CREATE OR REPLACE FUNCTION public.strans_invert(strans)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_invert$function$

CREATE OR REPLACE FUNCTION public.strans_line(sline, strans)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_line$function$

CREATE OR REPLACE FUNCTION public.strans_line_inverse(sline, strans)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_line_inverse$function$

CREATE OR REPLACE FUNCTION public.strans_not_equal(strans, strans)
 RETURNS boolean
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_not_equal$function$

CREATE OR REPLACE FUNCTION public.strans_path(spath, strans)
 RETURNS spath
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_path$function$

CREATE OR REPLACE FUNCTION public.strans_path_inverse(spath, strans)
 RETURNS spath
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_path_inverse$function$

CREATE OR REPLACE FUNCTION public.strans_point(spoint, strans)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_point$function$

CREATE OR REPLACE FUNCTION public.strans_point_inverse(spoint, strans)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_point_inverse$function$

CREATE OR REPLACE FUNCTION public.strans_poly(spoly, strans)
 RETURNS spoly
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_poly$function$

CREATE OR REPLACE FUNCTION public.strans_poly_inverse(spoly, strans)
 RETURNS spoly
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_poly_inverse$function$

CREATE OR REPLACE FUNCTION public.strans_trans(strans, strans)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_trans$function$

CREATE OR REPLACE FUNCTION public.strans_trans_inv(strans, strans)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_trans_inv$function$

CREATE OR REPLACE FUNCTION public.strans_zxz(strans)
 RETURNS strans
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_zxz$function$

CREATE OR REPLACE FUNCTION public.sw(sbox)
 RETURNS spoint
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherebox_sw$function$

CREATE OR REPLACE FUNCTION public.swap(sline)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_swap_beg_end$function$
CREATE OR REPLACE FUNCTION public.swap(spath)
 RETURNS spath
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepath_swap$function$

CREATE OR REPLACE FUNCTION public.theta(strans)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spheretrans_theta$function$

CREATE OR REPLACE FUNCTION public.turn(sline)
 RETURNS sline
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$sphereline_turn$function$

CREATE OR REPLACE FUNCTION public.x(spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_x$function$

CREATE OR REPLACE FUNCTION public.xyz(spoint)
 RETURNS double precision[]
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_xyz$function$

CREATE OR REPLACE FUNCTION public.y(spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_y$function$

CREATE OR REPLACE FUNCTION public.z(spoint)
 RETURNS double precision
 LANGUAGE c
 IMMUTABLE STRICT
AS '$libdir/pg_sphere', $function$spherepoint_z$function$

