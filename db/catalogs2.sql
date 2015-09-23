CREATE SCHEMA public;

CREATE SEQUENCE public.cube_cub_id_seq START WITH 1;

CREATE SEQUENCE public.environment_env_id_seq START WITH 1;

CREATE SEQUENCE public.ephemeris_eph_id_seq START WITH 1;

CREATE SEQUENCE public.filename_fn_id_seq START WITH 1;

CREATE SEQUENCE public.image_img_id_seq START WITH 1;

CREATE SEQUENCE public.ligthcurve_lcv_id_seq START WITH 1;

CREATE SEQUENCE public.referencecat_ref_id_seq START WITH 1;

CREATE SEQUENCE public.srccat_src_id_seq START WITH 1;

CREATE SEQUENCE public.srccat_src_imgid_seq START WITH 1;

CREATE SEQUENCE public.statistics_sta_id_seq START WITH 1;

CREATE TABLE public.ccds ( 
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

COMMENT ON COLUMN public.ccds.ccd_id IS 'Primary key.';

COMMENT ON COLUMN public.ccds.ccd_detid IS 'CCD camera serial number.';

COMMENT ON COLUMN public.ccds.ccd_usbhubnum IS 'Number of the USB hub where the CCD camera is connected.';

COMMENT ON COLUMN public.ccds.ccd_usbhubcon IS 'Number of the USB connector for a given USB hub where the CCD camera is connected.';

COMMENT ON COLUMN public.ccds.ccd_pwrblknum IS 'Number of the power distribution block where the CCD camera is connected.';

COMMENT ON COLUMN public.ccds.ccd_pwrblkcon IS 'Number of the power line of a given distribution block where the CCD camera is connected.';

COMMENT ON COLUMN public.ccds.ccd_imagew IS 'Image CCD width along X axis.';

COMMENT ON COLUMN public.ccds.ccd_imageh IS 'Image CCD width along Y axis.';

COMMENT ON COLUMN public.ccds.ccd_ccdpxszx IS 'Pixel width in microns (after binning).';

COMMENT ON COLUMN public.ccds.ccd_ccdpxszy IS 'Pixel height in microns (after binning).';

COMMENT ON COLUMN public.ccds.ccd_instrume IS 'Name of CCD camera.';

CREATE TABLE public.environment ( 
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

COMMENT ON COLUMN public.environment.env_id IS 'Primary key.';

COMMENT ON COLUMN public.environment.env_domestatus IS 'Dome status.';

COMMENT ON COLUMN public.environment.env_winddir IS 'Wind direction (deg)';

COMMENT ON COLUMN public.environment.env_windsped IS 'Wind speed (m/s).';

COMMENT ON COLUMN public.environment.env_outrelhu IS 'Outside relative humidity.';

COMMENT ON COLUMN public.environment.env_outdewpt IS 'Outside dew point.';

COMMENT ON COLUMN public.environment.env_indtemp IS 'Inside dome temperature.';

COMMENT ON COLUMN public.environment.env_inrelhu IS 'Inside dome relative humidity.';

COMMENT ON COLUMN public.environment.env_indewpt IS 'Inside dome dew point.';

COMMENT ON COLUMN public.environment.env_inmtemp IS 'Inside mushroom temperature.';

COMMENT ON COLUMN public.environment.env_inmrehu IS 'Inside mushroom relative humidity.';

COMMENT ON COLUMN public.environment.env_rain IS 'Rain (0/1)';

COMMENT ON COLUMN public.environment.env_cloudnss IS 'Cloudiness (sky temp Ð ambient temp)';

COMMENT ON COLUMN public.environment.env_skybrgth IS 'Sky brightness (magáarcsec^-2)';

CREATE TABLE public.ephemeris ( 
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

COMMENT ON COLUMN public.ephemeris.eph_id IS 'Primary key.';

COMMENT ON COLUMN public.ephemeris.eph_moonaz IS 'Moon azimuth.';

COMMENT ON COLUMN public.ephemeris.eph_moonalt IS ' Moon altitude.';

COMMENT ON COLUMN public.ephemeris.eph_moonang IS 'Elongation between Moon and center of CCD (requires A.net solution).';

COMMENT ON COLUMN public.ephemeris.eph_moonphas IS 'Moon phase (%)';

COMMENT ON COLUMN public.ephemeris.eph_sunaz IS 'Sun azimuth.';

COMMENT ON COLUMN public.ephemeris.eph_sunalt IS 'Sun altitude.';

COMMENT ON COLUMN public.ephemeris.eph_sunang IS 'Elongation between Sun and center of CCD.';

CREATE TABLE public.evrproject ( 
	evr_id               smallint  NOT NULL,
	evr_prjdesc          varchar(255)  ,
	evr_prjpi            varchar(70)  ,
	evr_prjobser         varchar(70)  ,
	CONSTRAINT pk_evr_id PRIMARY KEY ( evr_id )
 );

COMMENT ON COLUMN public.evrproject.evr_id IS 'Primary key (Evrproject ID)';

COMMENT ON COLUMN public.evrproject.evr_prjdesc IS 'Project description.';

COMMENT ON COLUMN public.evrproject.evr_prjpi IS 'Project PI';

COMMENT ON COLUMN public.evrproject.evr_prjobser IS 'Project observer.';

CREATE TABLE public.filename ( 
	fn_id                bigserial  NOT NULL,
	fn_pathname          varchar(90)  ,
	fn_origname          varchar(70)  ,
	CONSTRAINT pk_fn_id PRIMARY KEY ( fn_id )
 );

COMMENT ON TABLE public.filename IS 'Lists path and filename of the individual FITS images.
Sometimes these columns may be left empty because the image has only been 
stored temporally.';

COMMENT ON COLUMN public.filename.fn_id IS 'Primary key';

COMMENT ON COLUMN public.filename.fn_pathname IS 'Path  where image file name is (temporally sometimes) stored.';

COMMENT ON COLUMN public.filename.fn_origname IS 'Filename of the individual image which is (sometimes temporally) stored.';

CREATE TABLE public.filters ( 
	fil_id               smallint  NOT NULL,
	fil_filter           varchar(30)  ,
	CONSTRAINT pk_fil_id PRIMARY KEY ( fil_id )
 );

COMMENT ON TABLE public.filters IS 'Filters';

COMMENT ON COLUMN public.filters.fil_id IS 'Primary key';

COMMENT ON COLUMN public.filters.fil_filter IS 'Filter name';

CREATE TABLE public.imgtype ( 
	imt_id               varchar(1)  NOT NULL,
	imt_imgtyp           varchar(50)  ,
	CONSTRAINT pk_imt_id PRIMARY KEY ( imt_id )
 );

COMMENT ON COLUMN public.imgtype.imt_id IS 'Primary key';

CREATE TABLE public.ligthcurve ( 
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

COMMENT ON TABLE public.ligthcurve IS 'To be populated with a PL/SQL procedure in a daily basis';

COMMENT ON COLUMN public.ligthcurve.lcv_id IS 'SEXtractor running object number of the sextractor reference catalog.';

COMMENT ON COLUMN public.ligthcurve.lcv_epoch IS 'Epoch of lightcurve source mesurement.';

COMMENT ON COLUMN public.ligthcurve.lcv_object IS 'Source identificator from (RA,DEC): JHHMMSSSS+DDMMSSS';

COMMENT ON COLUMN public.ligthcurve.lcv_ra IS 'RA(J2000) of the source in the SEXtractor reference catalog.';

COMMENT ON COLUMN public.ligthcurve.lcv_dec IS 'DEC(J2000) of the source in the SEXtractor reference catalog.';

COMMENT ON COLUMN public.ligthcurve.lcv_radec IS '(RAJ2000,DECJ2000) spherical data type for the position of the source in the SEXtractor reference catalog.';

COMMENT ON COLUMN public.ligthcurve.lcv_mag IS 'Magnitude of the source for the measurement at the given epoch.';

COMMENT ON COLUMN public.ligthcurve.lcv_magerr IS 'Magnitude error of the source for the measurement at the given epoch.';

CREATE TABLE public.referencecat ( 
	ref_id               bigserial  NOT NULL,
	ref_object           varchar(17)  ,
	ref_alphawin_j2000   float8  ,
	ref_deltawin_j2000   float8  ,
	CONSTRAINT pk_ref_id PRIMARY KEY ( ref_id )
 );

COMMENT ON TABLE public.referencecat IS 'SEXtractor photometry of all-sky source taken with Evryscope used as a reference catalog for future observations.';

COMMENT ON COLUMN public.referencecat.ref_id IS 'SEXtractor running reference object number.';

COMMENT ON COLUMN public.referencecat.ref_object IS 'Source identificator from (RA,DEC): JHHMMSSSS+DDMMSSS';

COMMENT ON COLUMN public.referencecat.ref_alphawin_j2000 IS 'Windowed right ascension (J2000).';

COMMENT ON COLUMN public.referencecat.ref_deltawin_j2000 IS 'Windowed declination (J2000).';

CREATE TABLE public."statistics" ( 
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

COMMENT ON COLUMN public."statistics".sta_id IS 'Primary key.';

COMMENT ON COLUMN public."statistics".sta_mean IS 'Mean of the whole image.';

COMMENT ON COLUMN public."statistics".sta_median IS 'Median of the whole image.';

COMMENT ON COLUMN public."statistics".sta_stdev IS 'Standard deviation of the whole image.';

COMMENT ON COLUMN public."statistics".sta_min IS 'Minimum pixel value of the whole image.';

COMMENT ON COLUMN public."statistics".sta_mintx IS 'Row of min pixel value of the whole image.';

COMMENT ON COLUMN public."statistics".sta_minty IS 'Column of min pixel value of the whole image.';

COMMENT ON COLUMN public."statistics".sta_max IS 'Maximum pixel value of the whole image.';

COMMENT ON COLUMN public."statistics".sta_maxtx IS 'Row of max pixel value of the whole image.';

COMMENT ON COLUMN public."statistics".sta_maxty IS 'Column of max pixel value of the whole image.';

CREATE TABLE public.telescope ( 
	tel_id               smallint  NOT NULL,
	tel_telescop         varchar(30)  ,
	tel_origin           varchar(20)  ,
	tel_obslat           real  ,
	tel_obslon           real  ,
	tel_obsalt           real  ,
	CONSTRAINT pk_tel_id PRIMARY KEY ( tel_id )
 );

COMMENT ON COLUMN public.telescope.tel_id IS 'Primary key.';

COMMENT ON COLUMN public.telescope.tel_telescop IS 'Name of the telescope.';

COMMENT ON COLUMN public.telescope.tel_origin IS 'Name of the site.';

COMMENT ON COLUMN public.telescope.tel_obslat IS 'Site geographical latitude (deg).';

COMMENT ON COLUMN public.telescope.tel_obslon IS 'Site geographical longitude (deg).';

COMMENT ON COLUMN public.telescope.tel_obsalt IS 'Site geographical altitude HMSL (m).';

CREATE TABLE public.image ( 
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
	CONSTRAINT fk_img_ccdid FOREIGN KEY ( img_ccdid ) REFERENCES public.ccds( ccd_id )    ,
	CONSTRAINT fk_img_nameid FOREIGN KEY ( img_nameid ) REFERENCES public.filename( fn_id )    ,
	CONSTRAINT fk_img_typid FOREIGN KEY ( img_typid ) REFERENCES public.imgtype( imt_id )    ,
	CONSTRAINT fk_img_telid FOREIGN KEY ( img_telid ) REFERENCES public.telescope( tel_id )    ,
	CONSTRAINT fk_img_filid FOREIGN KEY ( img_filid ) REFERENCES public.filters( fil_id )    ,
	CONSTRAINT fk_img_staid FOREIGN KEY ( img_staid ) REFERENCES public."statistics"( sta_id )    ,
	CONSTRAINT fk_img_envid FOREIGN KEY ( img_envid ) REFERENCES public.environment( env_id )    ,
	CONSTRAINT fk_img_ephid FOREIGN KEY ( img_ephid ) REFERENCES public.ephemeris( eph_id )    ,
	CONSTRAINT fk_img_evrid FOREIGN KEY ( img_evrid ) REFERENCES public.evrproject( evr_id )    
 );

COMMENT ON TABLE public.image IS 'Lists metadata of non-compressed individual FITS images.
For saving storage reasons these FITS files are not stored 
on disk uncompressed and individually, but ina MEF (cube) fashion 
and fpack compressed (see cube table).';

COMMENT ON COLUMN public.image.img_id IS 'Primary key';

COMMENT ON COLUMN public.image.img_typid IS 'Foreign key for imgtype.img_typeid to indicate the exposure type.
b:bias;k:dark;f:focus;s:skyflat;o:object/science;t:test;p:pointing';

COMMENT ON COLUMN public.image.img_nameid IS 'Foreign key of name.name_id for storing path and name of the image file.';

COMMENT ON COLUMN public.image.img_ccdid IS 'Foreign key for ccd.ccd_id to indicate those static atributes of the CCDs';

COMMENT ON COLUMN public.image.img_telid IS 'Foreign key for telescope.tel_id';

COMMENT ON COLUMN public.image.img_filid IS 'Foreign key for filter.filt_id';

COMMENT ON COLUMN public.image.img_staid IS 'Foreign key for statistics.sta_id';

COMMENT ON COLUMN public.image.img_envid IS 'Foreign key for environment.env_id';

COMMENT ON COLUMN public.image.img_ephid IS 'Foreign key for ephemeris.eph_id';

COMMENT ON COLUMN public.image.img_evrid IS 'Foreign key for evrproject.evrprj_id';

COMMENT ON COLUMN public.image.img_naxis1 IS 'image naxis1';

COMMENT ON COLUMN public.image.img_naxis2 IS 'image naxis2';

COMMENT ON COLUMN public.image.img_bitpix IS 'image bitpix';

COMMENT ON COLUMN public.image.img_bscale IS 'image bscale';

COMMENT ON COLUMN public.image.img_bzero IS 'image bzero';

COMMENT ON COLUMN public.image.img_utc IS 'timestamp of obsevation in UTC';

COMMENT ON COLUMN public.image.img_obslst IS 'time for Local Sidereal Time';

COMMENT ON COLUMN public.image.img_obsdate IS 'image observation date in UTC';

COMMENT ON COLUMN public.image.img_obstime IS 'image observation time in UTC';

COMMENT ON COLUMN public.image.img_obsmjd IS 'image observation timestamp in modified Julian date';

COMMENT ON COLUMN public.image.img_obshmjd IS 'image observation timestamp in heliocentric modified Julian date';

COMMENT ON COLUMN public.image.img_mountra IS 'Pointed mount RA (J2000)';

COMMENT ON COLUMN public.image.img_mountdec IS 'Pointed mount DEC (J2000)';

COMMENT ON COLUMN public.image.img_mounthr IS 'Pointed mount Hour angle (0-24h)';

COMMENT ON COLUMN public.image.img_mountazi IS 'Pointed mount Azimuth';

COMMENT ON COLUMN public.image.img_mountalt IS 'Pointed mount elevation';

COMMENT ON COLUMN public.image.img_equinox IS '(img_ra, img_dec) coordinates equinox';

COMMENT ON COLUMN public.image.img_ra IS 'RA of central CCD pixel as per A.net astrometric reduction';

COMMENT ON COLUMN public.image.img_dec IS 'DEC of central CCD pixel as per A.net astrometric reduction';

COMMENT ON COLUMN public.image.img_radec IS '(RA,DEC) spherical data type of central CCD pixel as A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_ra2k IS 'RA(J2000) of central CCD pixel as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_dec2k IS 'DEC(J2000) of central CCD pixel as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_radec2k IS '(RAJ2000,DECJ2000) of central CCD pixel as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_longpole IS 'Longitude of the pole of the coordinate system.';

COMMENT ON COLUMN public.image.img_latpole IS 'Latitude of the pole of the coordinate system.';

COMMENT ON COLUMN public.image.img_wcsaxes IS 'Number of WCS axes.';

COMMENT ON COLUMN public.image.img_ctype1 IS 'WCS Type of the horizontal coordinate, including coordinate and projection.';

COMMENT ON COLUMN public.image.img_ctype2 IS 'WCS Type of the vertical coordinate, including coordinate and projection.';

COMMENT ON COLUMN public.image.img_crval1 IS 'RA  of reference point (RA at tangential point)  as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_crval2 IS 'DEC of reference point (DEC at tangential point) as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_crpix1 IS 'X reference pixel (X pixel value at tangential point)  as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_crpix2 IS 'Y reference pixel (Y pixel value at tangential point) as per A.net astrometric reduction.';

COMMENT ON COLUMN public.image.img_cunit1 IS 'Units of horizontal spherical coordinates.';

COMMENT ON COLUMN public.image.img_cunit2 IS 'Units of vertical spherical coordinates.';

COMMENT ON COLUMN public.image.img_cd1_1 IS 'WCS transformation matrix: partial of first axis coordinate w.r.t. X.';

COMMENT ON COLUMN public.image.img_cd1_2 IS 'WCS transformation matrix: partial of first axis coordinate w.r.t. Y.';

COMMENT ON COLUMN public.image.img_cd2_1 IS 'WCS transformation matrix: partial of second axis coordinate w.r.t. X.';

COMMENT ON COLUMN public.image.img_cd2_2 IS 'WCS transformation matrix: partial of second axis coordinate w.r.t. Y.';

COMMENT ON COLUMN public.image.img_pixscale IS 'Pixel scale (arcsec/pix)';

COMMENT ON COLUMN public.image.img_airmass IS 'Airmass of central pixel of the CCD as per A.net astrometric reduction';

COMMENT ON COLUMN public.image.img_exptime IS 'Exposure time';

COMMENT ON COLUMN public.image.img_settemp IS 'CCD set point temp (C)';

COMMENT ON COLUMN public.image.img_ccdcpwr IS 'CCD cooler power percentage';

COMMENT ON COLUMN public.image.img_ccdtemp IS 'Actual CCD temp (C)';

COMMENT ON COLUMN public.image.img_ccdxbin IS 'Column binning';

COMMENT ON COLUMN public.image.img_ccdybin IS 'Row binning';

COMMENT ON COLUMN public.image.img_ccdroix IS 'Central X coordinate of Region Of Interest (ROI)';

COMMENT ON COLUMN public.image.img_ccdroiy IS 'Central Y coordinate of Region Of Interest (ROI)';

COMMENT ON COLUMN public.image.img_ccdroisx IS 'Region Of Interest (ROI) size along X';

COMMENT ON COLUMN public.image.img_ccdroisy IS 'Region Of Interest (ROI) size along Y';

COMMENT ON COLUMN public.image.img_ccdspeed IS 'CCD readout speed (Low/High)';

COMMENT ON COLUMN public.image.img_ccdrbifl IS 'CCD RBI flood (On/Off)';

COMMENT ON COLUMN public.image.img_focuspos IS 'Focus position';

COMMENT ON COLUMN public.image.img_defocus IS 'Defocus on purpose for some reason';

COMMENT ON COLUMN public.image.img_trackspd IS 'Tracking speed';

COMMENT ON COLUMN public.image.img_date IS 'Timestamp when file was written.';

COMMENT ON COLUMN public.image.img_checksum IS 'File checksum hash (SHA-1).';

CREATE TABLE public.sourcecat ( 
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
	CONSTRAINT fk_src_imgid FOREIGN KEY ( src_imgid ) REFERENCES public.image( img_id )    ,
	CONSTRAINT fk_src_id FOREIGN KEY ( src_id ) REFERENCES public.referencecat( ref_id )    
 );

COMMENT ON TABLE public.sourcecat IS 'SEXtractor photometry of each source on each individual FITS image.';

COMMENT ON COLUMN public.sourcecat.src_imgid IS 'ID of individual FITS image: foreign key.';

COMMENT ON COLUMN public.sourcecat.src_id IS 'SEXtractor running object number.';

COMMENT ON COLUMN public.sourcecat.src_flux_auto IS 'Flux within a Kron-like elliptical aperture.';

COMMENT ON COLUMN public.sourcecat.src_fluxerr_auto IS 'RMS error for AUTO flux.';

COMMENT ON COLUMN public.sourcecat.src_background IS 'Background at centroid position.';

COMMENT ON COLUMN public.sourcecat.src_flux_max IS 'Peak flux above background.';

COMMENT ON COLUMN public.sourcecat.src_xwin_image IS 'Windowed position estimate along x.';

COMMENT ON COLUMN public.sourcecat.src_ywin_image IS 'Windowed position estimate along y.';

COMMENT ON COLUMN public.sourcecat.src_alphawin_j2000 IS 'Windowed right ascension (J2000).';

COMMENT ON COLUMN public.sourcecat.src_deltawin_j2000 IS 'windowed declination (J2000).';

COMMENT ON COLUMN public.sourcecat.src_elongation IS 'A_IMAGE/B_IMAGE';

COMMENT ON COLUMN public.sourcecat.src_fwhm_image IS 'FWHM assuming a gaussian core.';

COMMENT ON COLUMN public.sourcecat.src_flags IS 'Extraction flags.';

CREATE TABLE public."cube" ( 
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
	CONSTRAINT fk_cub_imgid FOREIGN KEY ( cub_imgid ) REFERENCES public.image( img_id )    
 );

COMMENT ON TABLE public."cube" IS 'Lists compressed MEF cube files which are stored on disk, fpack-compressed.
Each cube contains CUB_NUMEXTS of extensions (images), which are foreign keyed by CUB_EXPID';

COMMENT ON COLUMN public."cube".cub_id IS 'primary key';

COMMENT ON COLUMN public."cube".cub_imgid IS 'Foreign key links to image.img_id';

COMMENT ON COLUMN public."cube".cub_ccdid IS 'CCD number: 0,...,26';

COMMENT ON COLUMN public."cube".cub_extnumber IS 'Extension number of the MEF (cube) file';

COMMENT ON COLUMN public."cube".cub_extname IS 'Name of the file of an individual extension in the MEF (cube) file.
cub_extname does not necesseraly to exist, since  it may be removed
once the cube is created.';

COMMENT ON COLUMN public."cube".cub_path IS 'Path where cubes are stored';

COMMENT ON COLUMN public."cube".cub_origname IS 'Filename of MEF (cube)';

COMMENT ON COLUMN public."cube".cub_compressed IS 'Is the cube compressed (True/False)';

COMMENT ON COLUMN public."cube".cub_numexts IS 'Number of extensions for each cube';

COMMENT ON COLUMN public."cube".cub_qfactor IS 'Value of compression factor q of fpack';

COMMENT ON COLUMN public."cube".cub_tile1 IS 'Number of pixels for tile dimension in x axis for fpack';

COMMENT ON COLUMN public."cube".cub_tile2 IS 'Number of pixels for tile dimension in y axis for fpack';

COMMENT ON COLUMN public."cube".cub_cmptype IS 'Compression algorithm used in fpack';

COMMENT ON COLUMN public."cube".cub_date IS 'Cube creation date';


