FUNCTION help_data, HELP_ip=help_ip
    IF KEYWORD_SET(help_ip) THEN BEGIN
        PRINT, 'Variable (options) and short description'
        PRINT,  'year       : year of the time series'
        PRINT,  'DOY        : Day of the year' 
        PRINT,  'hour       : Hour of the day. Format 24h, from 0 to 23 (UTC)'
        PRINT,  'Bartel     : Bartels rotation number'
        PRINT,  'id_ifm     : ID for IMF spacecraft'
        PRINT,  'id_sw      : ID for SW Plasma spacecraft'
        PRINT,  'n_pt_ifm   : # of points in IMF averages'
        PRINT,  'n_pt_plasm : # of points in Plasma averag.'
        PRINT,  'B_esc      : Scalar B, nT '
        PRINT,  'B_vec      : Vector B Magnitude,nT '
        PRINT,  'B_lat      : Lat. Angle of B (GSE)'
        PRINT,  'B_long     : Long. Angle of B (GSE)'
        PRINT,  'Bx         : BX, nT (GSE, GSM)'
        PRINT,  'By         : BY, nT (GSE)'
        PRINT,  'Bz         : BZ, nT (GSE)'
        PRINT,  'By0        : BY, nT (GSM)'
        PRINT,  'Bz0        : BZ, nT (GSM)'
        PRINT,  'B_rms_esc  : RMS_magnitude, nT '
        PRINT,  'B_rms_vec  : RMS_field_vector, nT '
        PRINT,  'Bx_rms     : RMS_BX_GSE, nT '
        PRINT,  'By_rms     : RMS_BY_GSE, nT '
        PRINT,  'Bz_rms     : RMS_BZ_GSE, nT '
        PRINT,  'Temp       : SW Plasma Temperature, K '
        PRINT,  'density_p  : SW Proton Density, N/cm^3'
        PRINT,  'v_p        : SW Plasma Speed, km/s'
        PRINT,  'flow_long  : SW Plasma flow long. angle '
        PRINT,  'flow_lat   : SW Plasma flow lat. angle'
        PRINT,  'alfa_prot  : Alpha/Prot. ratio'
        PRINT,  'sigma_T    : sigma-T,K'
        PRINT,  'sigma_n    : sigma-n, (N/cm^3)'
        PRINT,  'sigma_v    : sigma-V, km/s'
        PRINT,  'sigma_phi  : sigma-phi V, degrees'
        PRINT,  'sigma_thet : sigma-theta V, degrees'  
        PRINT,  'sigma_rat  : sigma-ratio'
        PRINT,  'p_dyn      : Flow pressure (dynamic Preassure)' 
        PRINT,  'E          : E elecrtric field'
        PRINT,  'beta_P     : Plasma Beta '
        PRINT,  'alfven_M   : Alfen mach number'
        PRINT,  'mag_M      : Magnetosonic Much num.'
        PRINT,  'q_invar    : Quasy-Invariant '
        PRINT,  'kp         : Kp index '  
        PRINT,  'R          : R (Sunspot No.) '
        PRINT,  'dst        : Dst-index, nT'
        PRINT,  'ap         : ap_index, nT '
        PRINT,  'f10_idx    : f10.7 index '
        PRINT,  'AE         : AE-index, nT'
        PRINT,  'AL         : AL-index, nT'
        PRINT,  'AU         : AU-index, nT'
        PRINT,  'pc_idx     : pc-index '
        PRINT,  'lyman_alfa : Lyman_alpha'
        PRINT,  'pflux_1MeV : Proton flux (>1 Mev)'
        PRINT,  'pflux_2MeV : Proton flux (>2 Mev)'
        PRINT,  'pflux_4MeV : Proton flux (>4 Mev)'
        PRINT,  'pflux_10MeV: Proton flux (>10 Mev)'
        PRINT,  'pflux_30MeV: Proton flux (>30 Mev)'
        PRINT,  'pflux_60MeV: Proton flux (>60 Mev)'
        PRINT,  'flux_FLAG  : Flux FLAG '
        PRINT,  '###############################################################################'
        PRINT,  'For better references, consult https://omniweb.gsfc.nasa.gov/form/dx1.html'
        PRINT,  '###############################################################################'
                                                    
    ENDIF
   ; RETURN
END    
