;Name:
;	kmex_array.pro
;purpose:
;	kmex:   Create data structure from local geomagnetic data index files from observatory/magnetic
;           station
;   kmex_array: generate k or a local index from the data structure generated in kmex function
;
;author:
;	Carlos Isaac Castellanos Velazco
;	Estudiante de Maestría en Ciencias de la Tierra
;	Instituto de Geofísica, Unidad Michoacan
;	UNAM
;	ccastellanos@igeofisica.unam.mx
;
;category:
;   data analysis
;
;calling sequence:
;   .r kmex_array
;   kmex_array(idate, fdate, variable)  
;
;parameters:
;   idate/fdate: format [yyyy,mm,dd]
;   variable    : vector array to be selected
;       options: 'k_mex' and 'a_mex'
;
;dependencies:
;   Geomagnetic Service
;   Geophysics Institute
;   National Space Weather Laboratory
;
;input files
;   Kmex and amex time series
;
;output files:
;   Kmex data structure
;
;version
; Dec, 2022


FUNCTION kmex, date
	On_error, 2
	COMPILE_OPT idl2, HIDDEN

	year	= date[0]
	month	= date[1]
	day 	= date[2]	
;###############################################################################
;reading data files
        date = STRING(year, month, day, FORMAT = '(I4, I02, I02)')
		
		name = 'teo_'+date+'.index.'
		path='/home/isaac/MEGAsync/datos'
		file_name = path+'/Kmex/'+name+'final'		
		
		file = FILE_SEARCH(file_name, COUNT=opened_files)
	    IF opened_files NE N_ELEMENTS(file) THEN BEGIN
	        file_name =  path+'/Kmex/'+name+'early'
	        file = FILE_SEARCH(file_name, COUNT=opened_files) 
    	    IF opened_files NE N_ELEMENTS(file) THEN MESSAGE, file_name+'not found'  	    
	    ENDIF

		number_of_lines = FILE_LINES(file)
		data = STRARR(number_of_lines)

		OPENR, lun, file, /GET_LUN, ERROR=err
		IF err NE 0 THEN MESSAGE, 'Error opening '+file_name[0]
		READF, lun, data, FORMAT = '(A)'
		CLOSE, lun
		FREE_LUN, lun
;###############################################################################
;extracting data and denfining an structure data
        idx_kmex      = {k_mex      : intarr(8), $
                         k_mex_sum  : 0, $
                         a_mex      : intarr(8), $
                         a_med      : 0}
        
        struct = {x : [0, 0, 0, 0, 0, 0, 0, 0], y : 0}        
        tmp_var = REPLICATE(struct, 2)
		READS, data, tmp_var, FORMAT='(I3, I4, I4, I4, I4, I4, I4, I4, I4)'
		
		idx_kmex.k_mex[*]   = tmp_var[0].x
		idx_kmex.a_mex[*]   = tmp_var[1].x
        idx_kmex.k_mex_sum  = tmp_var[0].y
        idx_kmex.a_med      = tmp_var[1].y				
		RETURN, idx_kmex	
END   


FUNCTION kmex_array, date_i, date_f, variable, HELP=help
	On_error, 2
	COMPILE_OPT idl2, HIDDEN

	yr_i	= date_i[0]
	mh_i	= date_i[1]
	dy_i 	= date_i[2]	

	yr_f	= date_f[0]
	mh_f	= date_f[1]
	dy_f 	= date_f[2] 

;###############################################################################    
    file_number    = (JULDAY(mh_f, dy_f, yr_f) - JULDAY(mh_i, dy_i, yr_i))+1  

; define DH variables
        data_path='/home/isaac/MEGAsync/datos'
        
        string_date        = strarr(file_number)
               
        data_file_name_km  = strarr(file_number)
        data_file_name_kp  = strarr(file_number)  
                       
        string_date_2    = strarr(file_number)
             
        FOR i=0ll, file_number-1 DO BEGIN
                tmp_year    = 0
                tmp_month   = 0
                tmp_day     = 0
                tmp_julday  = JULDAY(mh_i, dy_i, yr_i)

                CALDAT, tmp_julday+i, tmp_month, tmp_day, tmp_year
                string_date[i]    = string(tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)')	
                data_file_name_km[i] = data_path+'/Kmex/teo_'+string_date[i]+'.index.final'
                		       
		        file = FILE_SEARCH(data_file_name_km[i], COUNT=opened_files)
	            IF opened_files NE N_ELEMENTS(file) THEN begin
	                data_file_name_km[i] = data_path+'/Kmex/teo_'+string_date[i]+'.index.early'    
	            ENDIF 	
        	                            
        ENDFOR

        exist_data_file_km   = FILE_TEST(data_file_name_km)
        capable_to_plot_km   = N_ELEMENTS(where(exist_data_file_km EQ 1))

        IF capable_to_plot_km NE N_ELEMENTS(data_file_name_km) THEN BEGIN 
                PRINT, FORMAT="('CRITICAL ERROR: impossible to read data file(s).')"
                PRINT, FORMAT="('                missing GMS_YYYYMMDD.km_index.',A,' impossible to plot all data.')"              
        ENDIF
;###############################################################################
; Generate the time variables to plot kmex time series 
        k_mex    = fltarr(file_number*8)
        a_mex    = INTARR(file_number*8)
        FOR i = 0, N_ELEMENTS(exist_data_file_km)-1 DO BEGIN
                IF exist_data_file_km[i] EQ 1 THEN BEGIN
                        tmp_year    = 0
                        tmp_month   = 0
                        tmp_day     = 0
                        READS, string_date[i], tmp_year, tmp_month, tmp_day, FORMAT='(I4,I02,I02)'                 
                        d_km = kmex([tmp_year, tmp_month, tmp_day])
                        
                        k_mex[i*8:(i+1)*8-1] = d_km.k_mex[*]/10.
                        a_mex[i*8:(i+1)*8-1] = d_km.a_mex[*]
                ENDIF             
        ENDFOR
 
    CASE variable of    
        'k_mex'    : variable = k_mex 
        'a_mex'    : variable = a_mex
        ELSE : PRINT, 'variable selected is not avaiable or valid'                 
    ENDCASE

    RETURN, variable

END  
