Library ieee;
use IEEE.STD_Logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Module Generates Video Sync Signals for Video Montor Interface
-- RGB and Sync outputs tie directly to monitor conector pins
ENTITY VGA_sync IS   
	PORT(
		CLOCK,RESET: IN std_logic;
		HOR_SYN,VER_SYN,video_on: OUT std_logic;
        row_counter:out INTEGER RANGE 0 TO 525;		
        col_counter:out INTEGER RANGE 0 TO 799	);
END VGA_sync ;

ARCHITECTURE arch OF VGA_sync IS
SIGNAL h_count: INTEGER RANGE 0 TO 799;			
SIGNAL v_count: INTEGER RANGE 0 TO 524;		
BEGIN

--Generate Horizontal and Vertical Timing Signals for Video Signal
-- 
--  Horiz_sync  ------------------------------------__________--------
--  h_count     0                 639              660      755      799
--
	PROCESS(CLOCK,RESET)   
	BEGIN				  						
     IF RESET = '0' THEN  h_count <=0;
     ELSIF CLOCK'EVENT AND CLOCK='1' THEN 
          IF h_count = 799 then h_count<=0;          
		  ELSE h_count <= h_count + 1;
     	  END IF;
     END IF;
	END PROCESS;

--  Vert_sync   ----------------------------------_______------------
--  v_count         0             479            493   494         524
--
   PROCESS(CLOCK,RESET)    
	BEGIN				  						
     IF RESET = '0' THEN v_count <=0;
     ELSIF CLOCK'EVENT AND CLOCK='1' THEN 
         IF h_count = 799 then 
			IF v_count = 524 THEN v_count <=0;
			ELSE v_count <= v_count+1;     
			END IF;
         END IF;
    END IF;
	END PROCESS;

--Generate Horizontal Sync Signal using h_count	
  PROCESS (h_count)  
    BEGIN
		IF h_count >=660 and h_count<=755 THEN HOR_SYN <= '0';
		ELSE  HOR_SYN <= '1';
		END IF;  	
  END PROCESS;
  
--Generate Vertical Sync Signal using v_count
   PROCESS (v_count)  
 	BEGIN
		IF (v_count >= 493 AND v_count <=494) THEN VER_SYN <= '0';
		ELSE VER_SYN <= '1';
		END IF;  	
	END PROCESS; 

-- Generate Video on Screen Signals for Pixel Data
-- Video on = 1 indicates pixel are being displayed
  process (h_count, v_count)  
	begin
		 IF v_count >=480 and v_count<=524 THEN video_on<='0';  
         ELSE 
			IF h_count >=640 and h_count<=799 THEN video_on<='0';
			ELSE video_on<='1';
			END IF;
     	END IF;
end process;

row_counter<=v_count;
col_counter<=h_count;

END arch;

