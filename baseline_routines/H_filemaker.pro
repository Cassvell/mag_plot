;
;Name:
;	H_filemaker.pro
;purpose:
;	derivación de las líneas base de dia a dia a partir de archivos raw
;author:
;	Carlos Isaac Castellanos Velazco
;	Estudiante de Maestría en Ciencias de la Tierra
;	Instituto de Geofísica, Unidad Michoacan
;	UNAM
;	ccastellanos@igeofisica.unam.mx
;
;category:
;   data generator
;
;calling sequence:
;   .r H_filmaker
;   H_filmaker, idate[yyyy,mm,dd], fdate[yyyy,mm,dd], MAKE_FILE=make_file
;parameters:
;   KEYWORD = make_file. Set this keyword to generate H data files in minute and hourly resolution
;
;dependencies:
;
;
;input files
;   geomagnetic field raw measurements from a certain observatory or geomagnetic station.
;
;output files:
;   .dat file of H data with no day to day variation
;
;   imported to: 
;version
;   Dec, 2022
;   Feb, 2023
;   Jun, 2023
;
;note
;   For following analysis, this routine has to be run to create clean H obs data
;

FUNCTION rawH, date, station, idx

	On_error, 2
	COMPILE_OPT idl2, HIDDEN

	year	= date[0]
	month	= date[1]
	day 	= date[2]
        @set_up_commons
        set_up		
;###############################################################################
;reading data files
;###############################################################################
        date = STRING(year, month, day, FORMAT = '(I4, I02, I02)')		
        str_year = STRING(year, FORMAT = '(I4)')	
        station_code    = set_var.gms_code[idx]   ;0;coe, 1:teo, 2:tuc, 3:bsl, 4:itu


    CASE station_code of
        'coe'   : gms_net = 'regmex'
        'teo'   : gms_net = 'regmex'
        'tuc'   : gms_net = 'intermagnet'
        'bsl'   : gms_net = 'intermagnet'
        ELSE : PRINT, 'non avaiable gms data'
    ENDCASE

		
    IF gms_net EQ 'regmex' THEN BEGIN 		
		data_dir = set_var.Mega_dir+station+'/'+station+'/'
		file_name = data_dir+station_code+'_'+date+'.clean.dat'
       ; print, file_name
		file = FILE_SEARCH(file_name, COUNT=opened_files)
		IF opened_files NE N_ELEMENTS(file) THEN MESSAGE, file_name+' not found'

		number_of_lines = FILE_LINES(file)
		data = STRARR(number_of_lines)

		OPENR, LUN, file, /GET_LUN, ERROR=err
		READF, LUN, data, FORMAT = '(A)'
		CLOSE, LUN
		FREE_LUN, LUN
;###############################################################################
;extracting data and denfining an structure data
;###############################################################################
        DStruct = {year:0, month:0, day:0, hour:0, minutes:0, DOY:0, $ 
                   D:0., H:0., Z:0., F:0.}

		teo_mag = REPLICATE(DStruct, number_of_lines)	
        header = 0             ; Defining number of lines of the header 

		READS, data[header:number_of_lines-1], teo_mag, $
		FORMAT='(I4,X,I02,X,I02,X,I02,X,I02,8X,I03,F12,F10,F10,F10)'
    ENDIF
    
    IF gms_net EQ 'intermagnet' THEN BEGIN

		data_dir = set_var.gic_dir+str_year+'/'+STRUPCASE(station_code)+'/daily/'
		file_name = data_dir+station_code+date+'qmin.min.out'

		file = FILE_SEARCH(file_name, COUNT=opened_files)
		IF opened_files NE N_ELEMENTS(file) THEN BEGIN
		    file_name = data_dir+station_code+date+'pmin.min.out'
		    file = FILE_SEARCH(file_name, COUNT=opened_files)
		ENDIF 
		
		
		IF opened_files NE N_ELEMENTS(file) THEN BEGIN
		    file_name = data_dir+station_code+date+'dmin.min.out'
		    file = FILE_SEARCH(file_name, COUNT=opened_files)		
        ENDIF

		
		IF opened_files NE N_ELEMENTS(file) THEN MESSAGE, file_name+' not found'

		number_of_lines = FILE_LINES(file)
		data = STRARR(number_of_lines)

		OPENR, LUN, file, /GET_LUN, ERROR=err
		READF, LUN, data, FORMAT = '(A)'
		CLOSE, LUN
		FREE_LUN, LUN
;###############################################################################
;extracting data and denfining an structure data
;###############################################################################
        DStruct = {year:0, month:0, day:0, hour:0, minuntes:0, DOY:0, $ 
                   X:0., Y:0., Z:0., F:0.}

		teo_mag = REPLICATE(DStruct, number_of_lines)	
        header = 0             ; Defining number of lines of the header 

		READS, data[header:number_of_lines-1], teo_mag, $
		FORMAT='(I4,X,I02,X,I02,X,I02,X,I02,8X,I03,F13,F10,F10,F10)'
    
    ENDIF
		RETURN, teo_mag		
END


FUNCTION rawH_array, date_i, date_f, station, idx
	On_error, 2
	COMPILE_OPT idl2, HIDDEN
	
	yr_i	= date_i[0]
	mh_i	= date_i[1]
	dy_i 	= date_i[2]	

	yr_f	= date_f[0]
	mh_f	= date_f[1]
	dy_f 	= date_f[2]

        @set_up_commons
        set_up
        
        file_number    = (JULDAY(mh_f, dy_f, yr_f) - JULDAY(mh_i, dy_i, yr_i))+1
        data_file_name = STRARR(file_number)
        string_date     = STRARR(file_number)
        str_year = STRING(yr_i, FORMAT = '(I4)')
        station_code    = set_var.gms_code[idx]   ;0;coe, 1:teo, 2:tuc, 3:bsl, 4:itu

    CASE station_code of
        'coe'   : gms_net = 'regmex'
        'teo'   : gms_net = 'regmex'
        'tuc'   : gms_net = 'intermagnet'
        'bsl'   : gms_net = 'intermagnet'
        ELSE : PRINT, 'non avaiable gms data'
    ENDCASE
    	
    IF gms_net EQ 'regmex' THEN BEGIN 
		        
       dir = set_var.Mega_dir+station+'/'+station+'/'
        FOR i=0ll, file_number-1 DO BEGIN
                tmp_year    = 0
                tmp_month   = 0
                tmp_day     = 0
                tmp_julday  = JULDAY(mh_i, dy_i, yr_i)

                CALDAT, tmp_julday+i, tmp_month, tmp_day, tmp_year
                string_date[i]    = string(tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)')
                data_file_name[i] = dir+station_code+'_'+string_date[i]+'.clean.dat'
        ENDFOR

        exist_data_file   = FILE_TEST(data_file_name)
        capable_to_plot   = N_ELEMENTS(WHERE(exist_data_file EQ 1))

        IF capable_to_plot NE N_ELEMENTS(data_file_name) THEN BEGIN 
                PRINT, FORMAT="('CRITICAL ERROR: impossible to read data file(s).')"
                PRINT, FORMAT="('                missing GMS_YYYYMMDD.H data.',A,' impossible to plot all data.')"              
        ENDIF

        H    = FLTARR(file_number*1440)                               
        FOR i = 0, N_ELEMENTS(exist_data_file)-1 DO BEGIN
                IF exist_data_file[i] EQ 1 THEN BEGIN
                        tmp_year    = 0
                        tmp_month   = 0
                        tmp_day     = 0
                        READS, string_date[i], tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)'
                        dat = rawH([tmp_year, tmp_month, tmp_day], station, idx)
                        
                        H[i*1440:(i+1)*1440-1] = dat.H[*]                                                
                ENDIF ELSE BEGIN
                         H[i*1440:(i+1)*1440-1] = 999999.0                       
                ENDELSE                
        ENDFOR
    ENDIF
    
    IF gms_net EQ 'intermagnet' THEN BEGIN 
       dir = set_var.gic_dir+str_year+'/'+STRUPCASE(station_code)+'/daily/'
        FOR i=0ll, file_number-1 DO BEGIN
                tmp_year    = 0
                tmp_month   = 0
                tmp_day     = 0
                tmp_julday  = JULDAY(mh_i, dy_i, yr_i)

                CALDAT, tmp_julday+i, tmp_month, tmp_day, tmp_year
                string_date[i]    = STRING(tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)')
                data_file_name[i] = dir+station_code+string_date[i]+'qmin.min.out'
                ;print, data_file_name[i]
                file = FILE_SEARCH(data_file_name[i], COUNT=opened_files)
	            IF opened_files NE N_ELEMENTS(file) THEN BEGIN
	                data_file_name[i] = dir+station_code+string_date[i]+'pmin.min.out'
	                file = FILE_SEARCH(data_file_name[i], COUNT=opened_files)  
	            ENDIF; 
	             IF opened_files NE N_ELEMENTS(file) THEN BEGIN
	                data_file_name[i] = dir+station_code+string_date[i]+'dmin.min.out'
	                file = FILE_SEARCH(data_file_name[i], COUNT=opened_files)
	            ENDIF
	            ;PRINT, data_file_name[i]           
        ENDFOR

        exist_data_file   = FILE_TEST(data_file_name)
        capable_to_plot   = N_ELEMENTS(WHERE(exist_data_file EQ 1))

        IF capable_to_plot NE N_ELEMENTS(data_file_name) THEN BEGIN 
                PRINT, FORMAT="('CRITICAL ERROR: impossible to read data file(s).')"
                PRINT, FORMAT="('                missing GMS_YYYYMMDD.H data.',A,' impossible to plot all data.')"              
        ENDIF

        H    = FLTARR(file_number*1440)                               
        X    = FLTARR(file_number*1440) 
        Y    = FLTARR(file_number*1440)                          
        FOR i = 0, N_ELEMENTS(exist_data_file)-1 DO BEGIN
                IF exist_data_file[i] EQ 1 THEN BEGIN
                        tmp_year    = 0
                        tmp_month   = 0
                        tmp_day     = 0
                        READS, string_date[i], tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)'
                        dat = rawH([tmp_year, tmp_month, tmp_day], station, idx)
                        
                        X[i*1440:(i+1)*1440-1] = dat.X[*]  
                        Y[i*1440:(i+1)*1440-1] = dat.Y[*]                                              
                ENDIF ELSE BEGIN
                        X[i*1440:(i+1)*1440-1] = 99999.0
                        Y[i*1440:(i+1)*1440-1] = 99999.0                     
                ENDELSE                
        ENDFOR
        X = add_nan(X, 99999.0, 'equal')        
        Y = add_nan(Y, 99999.0, 'equal')
        H = SQRT((X)^2 + (Y)^2)
       ; PRINT, X
    ENDIF
    
    
    RETURN, H
END


PRO H_filemaker, date_i, date_f, MAKE_FILE=make_file
	On_error, 2
	COMPILE_OPT idl2, HIDDEN

 ;   RESOLVE_ROUTINE, 'set_up',/COMPILE_FULL_FILE, /EITHER, /NO_RECOMPILE
        @set_up_commons
        set_up

	yr_i	= date_i[0]
	mh_i	= date_i[1]
	dy_i 	= date_i[2]	

	yr_f	= date_f[0]
	mh_f	= date_f[1]
	dy_f 	= date_f[2]
	
	station_idx = ''
	PRINT, 'Enter GMS idx: 0:coe, 1:teo, 2:tuc, 3:bsl, 4:itu'
	READ, station_idx, PROMPT = '> '
;###############################################################################    
    file_number    = (JULDAY(mh_f, dy_f, yr_f) - JULDAY(mh_i, dy_i, yr_i))+1 
    tot_days= FINDGEN(file_number*24)/24.0    
    Date    = STRING(yr_i, mh_i, dy_i, FORMAT='(I4, "-", I02, "-", I02)')

    station         = set_var.gms[FIX(station_idx)]        ;0:coeneo, 1:teoloyuca, 2:tucson, 3:bsl, 4:iturbide
    station_code    = set_var.gms_code[FIX(station_idx)]   ;0;coe, 1:teo, 2:tuc, 3:bsl, 4:itu
    
; Generate the time series variables 
; define H variables                  
    H  = rawH_array([yr_i, mh_i, dy_i], [yr_f, mh_f, dy_f], station, FIX(station_idx))

    H = add_nan(H, 999999.0, 'equal')        
    H = add_nan(H, 99999.0, 'equal')           
  ;  PRINT, H
;Applying a detrend function
    H_24h=FINDGEN(N_ELEMENTS(H)/1440)   
    FOR i=0, N_ELEMENTS(H_24h)-1 DO BEGIN
        H_24h[i] = MEDIAN(H[i*1440:(i+1)*1440-1])    
    ENDFOR
        
    IQR = PERCENTILES(H_24h, CONFLIMIT=0.5) 
    IQR_n = (IQR[1]-IQR[0])*1
 
    index_out = WHERE(H_24h GE MEDIAN(H_24h)+IQR_n OR H_24h LE MEDIAN(H_24h)-IQR_n[0])
    ;index_in  = WHERE(H_24h LE QR3 AND H_24h GE QR1)      
    time = FINDGEN(N_ELEMENTS(H))/1440
   ; PRINT, N_ELEMENTS(index_out)
   
    IF MIN(index_out) NE -1 THEN BEGIN
        H_24h[index_out] = !Values.F_NAN
        H_24h = fillnan(H_24h)
    ENDIF    
    PRINT, '#######################################################################'     
   ; PRINT, H_24h   
    ;PRINT, H_24h   
    PRINT, '#######################################################################'     
 
        
;plotting to check data    
    H_trend = INTERPOL(H_24h, N_ELEMENTS(time), /QUADRATIC)
    ;H_trend = INTERPOLATE(H_24h, x, CUBIC=-0.5,  /GRID, /MISSING)
    QR1 = cgPercentiles(H_trend, Percentiles=[0.25])  
    QR3 = cgPercentiles(H_trend, Percentiles=[0.75])
    n = 1
    IQR_n = (QR3-QR1)*n
    ;PRINT, QR1, QR3
    sup = MEDIAN(H_trend)+IQR_n
    inf = MEDIAN(H_trend)-IQR_n
    l_sup = FLTARR(N_ELEMENTS(H_trend))
    l_sup[*] = sup

    l_inf = FLTARR(N_ELEMENTS(H_trend))
    l_inf[*] = inf     
    
    PRINT, '#######################################################################'     
    
    ;
    trend = POLY_FIT(time, H_trend, 1,  YFIT=H_t)    	    
    ;H_t  = INTERPOL(H_trend, N_ELEMENTS(x), /QUADRATIC)
     
    H_det = H - H_trend

    dif_Hdet = TS_DIFF(H_det,2)
    IQR_diff = PERCENTILES(dif_Hdet, CONFLIMIT=0.96) 
    IQR_diff_n = (IQR_diff[1]-IQR_diff[0])*1.5
    med_diff  = MEDIAN(dif_Hdet)
    artfact = WHERE(dif_Hdet GE med_diff+IQR_diff_n OR dif_Hdet LE med_diff-IQR_diff_n[0])
    IF artfact[0] NE -1 THEN BEGIN    
        H_det[artfact] = !Values.F_NAN
    ENDIF
    
    ;outlayer = WHERE(H_det GT 100)

;    H_det[outlayer] = !Values.F_NAN    
    
    H_hr = FINDGEN(N_ELEMENTS(H_det)/60)
    FOR i=0, N_ELEMENTS(H_hr)-1 DO BEGIN
        H_hr[i] = MEDIAN(H_det[i*60:(i+1)*60-1])
          
    ENDFOR    
    
   ; PRINT, MIN(dif_Hdet, /NAN)

    DEVICE    

   ; set_plot, 'x'    
   WINDOW, 2, XSIZE=800, YSIZE=400, TITLE='H raw data'
    PLOT, time,H, YRANGE=[MIN(H, /NAN),MAX(H, /NAN)], XSTYLE=1, COLOR=255
    OPLOT, time, H_trend, LINESTYLE=2, THICK=2
 ;   OPLOT, time, H_t, LINESTYLE=2, THICK=1
    OPLOT, time, l_sup, LINESTYLE=1, THICK=2
    OPLOT, time, l_inf, LINESTYLE=1, THICK=2    
   ; PRINT, H_t


    WINDOW, 3, XSIZE=800, YSIZE=400, TITLE='d2H/dT2'
    PLOT, time, TS_DIFF(H_det,2), YRANGE=[MIN(dif_Hdet, /NAN),MAX(dif_Hdet,/NAN)], XSTYLE=1
      
    PRINT, 'MIN Value within the time window'
    PRINT, MIN(H_det, /NAN)

    PRINT, 'Press click to get H_det value in a certain point until right mouse button is pressed'

    
    WINDOW, 0, XSIZE=800, YSIZE=400, TITLE='H detrending'
    PLOT, time, H_det, YRANGE=[MIN(H_det, /NAN),MAX(H_det,/NAN)], XSTYLE=1

    WHILE (!MOUSE.button NE 4) DO BEGIN  ; repeat printing H trend value until right mouse button is pressed
      CURSOR, x, y, /DOWN, /DATA
      PRINT, y    
    ENDWHILE 
    


IF KEYWORD_SET(make_file) THEN BEGIN    
    outfile = STRARR(file_number)    
;Generación de archivo en muestreo de horas 
    string_date     = STRARR(file_number)
    FOR i=0, file_number-1 DO BEGIN
        tmp_year    = 0
        tmp_month   = 0
        tmp_day     = 0
        string_year = 0
        tmp_julday  = JULDAY(mh_i, dy_i, yr_i)
        CALDAT, tmp_julday+i, tmp_month, tmp_day, tmp_year
        
        str_year = STRMID(STRING(tmp_year, format='(I4)'),2,2)
        
        string_date[i]    = STRING(tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)')                
        outfile[i] = set_var.Mega_dir+station+'/hourly/'+station_code+'_'+string_date[i]+'h'+'.dat'
        ;print, outfile[i]
        OPENW, LUN, outfile[i], /GET_LUN        
        PRINTF, LUN, H_hr[i*24:(i+1)*24-1], format='(F9.4)'
        CLOSE, LUN
        FREE_LUN, LUN    
    ENDFOR     
    
    FOR i=0, file_number-1 DO BEGIN
        tmp_year    = 0
        tmp_month   = 0
        tmp_day     = 0
        tmp_julday  = JULDAY(mh_i, dy_i, yr_i)
        CALDAT, tmp_julday+i, tmp_month, tmp_day, tmp_year
        string_date[i]    = STRING(tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)')        

        outfile[i] = set_var.Mega_dir+station+'/min/'+station_code+'_'+string_date[i]+'m.dat'    
        OPENW, LUN, outfile[i], /GET_LUN        
        PRINTF, LUN, H_det[i*1440:(i+1)*1440-1], format='(F9.4)'
        CLOSE, LUN
        FREE_LUN, LUN    
    ENDFOR      



   ; PRINT, MIN(dif_Hdet, /NAN)

    DEVICE    

   ; set_plot, 'x'    
   WINDOW, 2, XSIZE=800, YSIZE=400, TITLE='H raw data'
    PLOT, time,H, YRANGE=[MIN(H, /NAN),MAX(H, /NAN)], XSTYLE=1, COLOR=255
    OPLOT, time, H_trend, LINESTYLE=2, THICK=2
 ;   OPLOT, time, H_t, LINESTYLE=2, THICK=1
    OPLOT, time, l_sup, LINESTYLE=1, THICK=2
    OPLOT, time, l_inf, LINESTYLE=1, THICK=2    
   ; PRINT, H_t

      
    WINDOW, 3, XSIZE=800, YSIZE=400, TITLE='H detrending'
    PLOT, time, H_det, YRANGE=[MIN(H_det, /NAN),MAX(H_det,/NAN)], XSTYLE=1

    PRINT, 'MIN Value within the time window'
    PRINT, MIN(H_det, /NAN)
    
    PRINT, 'Press click to get H_det value in a certain point until right mouse button is pressed'
    WHILE (!MOUSE.button NE 4) DO BEGIN  ; repeat printing H trend value until right mouse button is pressed
      CURSOR, x, y, /DOWN, /DATA
      PRINT, y    
    ENDWHILE 

 



    WINDOW, 0, XSIZE=800, YSIZE=400, TITLE='d2H/dT2'
    PLOT, time, TS_DIFF(H_det,2), YRANGE=[MIN(dif_Hdet, /NAN),MAX(dif_Hdet,/NAN)], XSTYLE=1

ENDIF
RETURN

END
