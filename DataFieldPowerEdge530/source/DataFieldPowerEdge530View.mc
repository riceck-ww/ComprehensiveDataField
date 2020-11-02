using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Graphics as Gfx;
using Toybox.Math as Mat;
using Toybox.AntPlus as Ant;
using Toybox.Sensor;

class DataFieldPowerEdge530View extends Ui.DataField {

      
    var counter;
    var label;
    var time;
    var timer="0:00:00";
    var spd=0;
    var cad=0;
    var acad=0;
    var pwr=0;
    var hr=0;
    var hdg=0;
    var bear=0;
    var aspd=0;
    var ahr=0;
    var hgt=0;
    var dst=0;
    var np=0.1;
    var batterie=1.0f;
    var dunits=0; //0=metric 1=statue
    var eunits=0; //0=metric 1=statue
    var counter_disp_grade_vspd=0;
    var fontColor;
    var fontColorBackground;
    var activityStarted=false;
   
   
    var grade=0.0f;
    
    var vSpeed=0;
   // var rollingavg_grade_period=5;
    hidden var counter2=0;
    hidden var distance=0.0f;
    hidden var altgain=0.0f;
    hidden var previousheight;
    hidden var alt_over_time = new [rollingAveragePeriod5];
    hidden var speed_over_time =new [rollingAveragePeriod5];
   // hidden var horizontal;
  //  var vSpeed_over_time = [0.0,0.0,0.0];
  	var igh=0;
    
    
    
    var formatierung2;
    var formatierung3;
    var formatierung4;
    
    var powerListener;
    var powerActual;
    var powerBalance=0;
    var torqueEffectL=0.0;
    var torqueEffectR=0.0;
   
   
   var rollingAveragePeriod = 30;        
   var rollingAverageArray; 
   var poulationCount = 0;
   var initialCount = 0;
   var wattsToThe4Total = 0;
   var normalisedCount = 0;
   
   var rollingAveragePeriod5 = 5;        
   var rollingAverageArray5 = new [rollingAveragePeriod5];
   var poulationCount5 = 0;
   var initialCount5 = 0;
   
   var power_level=[0,63,138,188,225,263,300,375,2000,5000];
   var hr_level=[0,95,114,131,150,168,190,5000];
 
   var colors_hr= new [10];
   var colors_pwr= new [11];
   var col_for_pwr;
   var col_for_hr;
   
   var hr_range=30;
   var pwr_range=100;
   var cad_range=15;
   var spd_range=5;
   var bal_pwr_range=10;
   
   var pfeil=new[8];
   var pfeil2=new[8];
   var pfeil_r=new[8];
   
   var pointer;
   
   var timeNow;
   
   var navDistance;
   var navETTA;  // in seconds
   var navState=false;
   
   var backgrWhite=true;
   var paused=false;
   
   var powBalAvg = [50, 50, 50];
   var counterPowBal= 0;
   
  

    function initialize() {
        DataField.initialize();
        
            
        colors_pwr[0]=0x333333;
        colors_pwr[1]=0x333333;
        colors_pwr[2]=0x0000FF;
        colors_pwr[3]=0xAAAAFF;
        colors_pwr[4]=Gfx.COLOR_GREEN;
        colors_pwr[5]=Gfx.COLOR_YELLOW;
        colors_pwr[6]=Gfx.COLOR_ORANGE;
        colors_pwr[7]=Gfx.COLOR_RED;
      	colors_pwr[8]=Gfx.COLOR_DK_RED;
        colors_pwr[9]=Gfx.COLOR_DK_RED;
        colors_pwr[10]=Gfx.COLOR_DK_RED;
        
        
        colors_hr[0]=0x333333;
        colors_hr[1]=0x0000FF;
        colors_hr[2]=0xAAAAFF;
        colors_hr[3]=Gfx.COLOR_GREEN;
        colors_hr[4]=Gfx.COLOR_YELLOW;
      	colors_hr[5]=Gfx.COLOR_RED;
        colors_hr[6]=Gfx.COLOR_DK_RED;
        colors_hr[7]=Gfx.COLOR_DK_RED;
        colors_hr[7]=Gfx.COLOR_DK_RED;
        colors_hr[7]=Gfx.COLOR_DK_RED;
        
        
        var mySetting1 = Application.getApp().getProperty("FTP");
        var mySetting2 = Application.getApp().getProperty("maxHR");
        var mySetting3 = Application.getApp().getProperty("rollAvg");
        if (mySetting3!=null){rollingAveragePeriod=mySetting3;}
       	rollingAverageArray = new [rollingAveragePeriod];

 
 		
 		if (mySetting1 != null){
 			power_level[1]=Math.ceil(0.25 * mySetting1);
 			power_level[2]=Math.ceil(0.55 * mySetting1);
 			power_level[3]=Math.ceil(0.75 * mySetting1);
 			power_level[4]=Math.ceil(0.9 * mySetting1);
 			power_level[5]=Math.ceil(1.05 * mySetting1);
 			power_level[6]=Math.ceil(1.2 * mySetting1);
 			power_level[7]=Math.ceil(1.5 * mySetting1);
 			
 		
 		}
 		
 		if (mySetting2 != null){
 			hr_level[1]=Math.ceil(0.5 * mySetting2);
 			hr_level[2]=Math.ceil(0.6 * mySetting2);
 			hr_level[3]=Math.ceil(0.7 * mySetting2);
 			hr_level[4]=Math.ceil(0.8 * mySetting2);
 			hr_level[5]=Math.ceil(0.91 * mySetting2);
 			hr_level[6]=Math.ceil(1.0 * mySetting2);
 			hr_level[7]=Math.ceil(1.0 * mySetting2);
 			
 		
 		}
    
  
       powerListener = new Ant.BikePowerListener();
       powerActual = new Ant.BikePower(powerListener);
       
       pfeil[0] = Ui.loadResource( Rez.Drawables.pfeil0 );
       pfeil[1] = Ui.loadResource( Rez.Drawables.pfeil1 );
       pfeil[2] = Ui.loadResource( Rez.Drawables.pfeil2 );
       pfeil[3] = Ui.loadResource( Rez.Drawables.pfeil3 );
       pfeil[4] = Ui.loadResource( Rez.Drawables.pfeil4 );
       pfeil[5] = Ui.loadResource( Rez.Drawables.pfeil5 );
       pfeil[6] = Ui.loadResource( Rez.Drawables.pfeil6 );
       pfeil[7] = Ui.loadResource( Rez.Drawables.pfeil7 );


 	   pfeil_r[0] = Ui.loadResource( Rez.Drawables.pfeilr0 );
       pfeil_r[1] = Ui.loadResource( Rez.Drawables.pfeilr1 );
       pfeil_r[2] = Ui.loadResource( Rez.Drawables.pfeilr2 );
       pfeil_r[3] = Ui.loadResource( Rez.Drawables.pfeilr3 );
       pfeil_r[4] = Ui.loadResource( Rez.Drawables.pfeilr4 );
       pfeil_r[5] = Ui.loadResource( Rez.Drawables.pfeilr5 );
       pfeil_r[6] = Ui.loadResource( Rez.Drawables.pfeilr6 );
       pfeil_r[7] = Ui.loadResource( Rez.Drawables.pfeilr7 );



	   pfeil2[0] = Ui.loadResource( Rez.Drawables.pfeil2_0 );
	   pfeil2[1] = Ui.loadResource( Rez.Drawables.pfeil2_w_0 );
       pfeil2[2] = Ui.loadResource( Rez.Drawables.pfeil2_90);
       pfeil2[3] = Ui.loadResource( Rez.Drawables.pfeil2_w_90);
       pfeil2[4] = Ui.loadResource( Rez.Drawables.pfeil2_180);
       pfeil2[5] = Ui.loadResource( Rez.Drawables.pfeil2_w_180);
       pfeil2[6] = Ui.loadResource( Rez.Drawables.pfeil2_270);
       pfeil2[7] = Ui.loadResource( Rez.Drawables.pfeil2_w_270);      
       
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
       
         
    }
    
    function onTimerPause(){
		paused=true;
	}
	
	function onTimerResume(){
		paused=false;
	}

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var min="";
        if (Sys.getClockTime().min < 10) {min="0";}
        else {min="";}
        timeNow=Sys.getClockTime().hour+":"+min+Sys.getClockTime().min;
        
         if (Sys.getDeviceSettings().elevationUnits) {eunits=1;}
   		else {eunits=0;} 
   		if (Sys.getDeviceSettings().distanceUnits) {dunits=1;}
   		else {dunits=0;} 
    
            if( info.currentHeartRate != null )
            {
                hr = info.currentHeartRate;
            }
 			       if( info.averageHeartRate != null )
            {
                ahr = info.averageHeartRate;
            }
                    if( info.currentSpeed != null )
            {
                spd = (1 - dunits * (1-0.621371))*info.currentSpeed * 3.6;
            }
                   if( info.averageSpeed != null )
            {
                aspd = (1 - dunits * (1-0.621371))*info.averageSpeed * 3.6;
            }
                  
                   if( info.currentCadence != null )
            {
                cad = info.currentCadence;
            }
            	if( info.averageCadence != null )
            {
                acad = info.averageCadence;
            }
                   if( info.altitude != null )
            {
                hgt = info.altitude * (1 + eunits * 2.28084);
            }
                   if( info.elapsedTime != null )
            {
                var dauer  = info.timerTime / 1000;
                var seconds = (dauer % 60);
                var minutes = ((dauer - seconds) / 60 ) % 60;
                var stunde = (dauer - minutes * 60 - seconds) / 3600;
                var minute_null = "";
                var sekunde_null="";
                
                if (minutes < 10){
                 minute_null="0";
                }
                else {
                 minute_null="";
                }
                 if (seconds < 10){
                 sekunde_null="0";
                }
                else {
                 sekunde_null="";
                }
                timer = ""+stunde+":"+minute_null+minutes+":"+sekunde_null+seconds;
                
                            }
                   if( info.elapsedDistance != null )
            {
                dst = (1 - dunits * (1-0.621371))*  info.elapsedDistance / 1000;
            } 
                 
              if( info.currentPower != null && paused==false)
            {
                np = calcNP(info.currentPower);
            }
            else
            {
               if (paused==false){
                np = calcNP(0);
               } 
            }   
            //  np=225; for test purposes
                if( info.currentPower != null )
            {
                pwr = calc5sPwr(info.currentPower);
            }
            else
            {
                pwr = calc5sPwr(0);
            }   
                 
             batterie=Sys.getSystemStats().battery;
             
            if(info.bearing != null){
             	bear=info.bearing;
             	//Sys.println("BEaring: "+bear);
 			}
 			
 			if(info.track != null){
             	hdg=info.track;
 			}
 			
            if( info.currentSpeed != null && info.altitude !=null ){
  			 	calcGradevSpeed (info.currentSpeed,info.altitude);
  			}
  			
  			if (powerActual.getPedalPowerBalance() !=null){
  				powerBalance=(powerActual.getPedalPowerBalance()).pedalPowerPercent;
  				}
 			if (powerActual.getTorqueEffectivenessPedalSmoothness() !=null){
 				try{
 					torqueEffectL=(powerActual.getTorqueEffectivenessPedalSmoothness()).leftTorqueEffectiveness; 		
  					torqueEffectR=(powerActual.getTorqueEffectivenessPedalSmoothness()).rightTorqueEffectiveness;
  				}
  				catch (e instanceof Lang.Exception) {
    				System.println(e.getErrorMessage());
				}
  			}
  			
  			
    		if (info.distanceToDestination!=null && info.averageSpeed!=null && info.distanceToDestination>0 && info.averageSpeed>0){
    			//Sys.println("Nav:"+info.distanceToDestination);
    			navDistance=info.distanceToDestination;
    			navETTA=(navDistance / info.averageSpeed).toNumber(); // in seconds
    			navState=true;
    		}
    		else{navState=false;}
    
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        if(getBackgroundColor()==Gfx.COLOR_WHITE) {
        	fontColor=Gfx.COLOR_BLACK;
        	fontColorBackground=Gfx.COLOR_WHITE;
        	backgrWhite=true;	
        }
        else{
        	fontColor=Gfx.COLOR_WHITE;
        	fontColorBackground=Gfx.COLOR_BLACK;
        	backgrWhite=false;
        
        }
      
        counter_disp_grade_vspd++;
        
         dc.setColor(fontColor, fontColorBackground);
        
   
   
         dc.drawText(12, 180, Graphics.FONT_XTINY, "+"+spd_range,
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         dc.drawText(12, 260, Graphics.FONT_XTINY, "-"+spd_range,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);           
      
         dc.drawText(230, 25, Graphics.FONT_XTINY, "+"+pwr_range,
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         dc.drawText(14, 25, Graphics.FONT_XTINY, "-"+pwr_range,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER); 
                    
      //   dc.drawText(120, 57, Graphics.FONT_XTINY, ""+(50-bal_pwr_range)+"%",
      //    			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
      //   dc.drawText(180, 57, Graphics.FONT_XTINY, ""+ (50+bal_pwr_range)+"%",
      //              Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);            
                    
     
         dc.drawText(235, 180, Graphics.FONT_XTINY, "+"+hr_range,
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         dc.drawText(235, 260, Graphics.FONT_XTINY, "-"+hr_range,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                    
                
                    
        var spd_delta = (spd - aspd);
        if (spd_delta>spd_range) {spd_delta=spd_range;}
        if (spd_delta<-spd_range) {spd_delta=-spd_range;}
        
        var cad_delta = (cad - acad);
        if (cad_delta>cad_range) {cad_delta=cad_range;}
        if (cad_delta<-cad_range) {cad_delta=-cad_range;}
        
        var hr_delta = (hr - ahr);
        if (hr_delta>hr_range) {hr_delta=hr_range;}
        if (hr_delta<-hr_range) {hr_delta=-hr_range;}
        
        var pwr_delta = (pwr - np);
        if (pwr_delta>pwr_range) {pwr_delta=pwr_range;}
        if (pwr_delta<-pwr_range) {pwr_delta=-pwr_range;}
                
                    
    
    	 
		 
       
		  for (var i=0;i<hr_level.size();++i) {
		  	if (hr<hr_level[i]){
		  		col_for_hr=colors_hr[i-1];
		  		break;
		   	}
		  }
		 
         dc.setColor(fontColor, Graphics.COLOR_TRANSPARENT);
         dc.drawText(230, 220, Graphics.FONT_SYSTEM_SMALL, ""+ahr,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER); 
		
                    
         dc.drawText(123, 92, Graphics.FONT_SYSTEM_SMALL, ""+np.format("%3.0f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER); 
       		
		 dc.drawText(15, 158, Graphics.FONT_XTINY, "CAD",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                            
                    
         dc.drawText(85, 178, Graphics.FONT_XTINY, "SPD",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                
                    
         dc.drawText(15, 105, Graphics.FONT_XTINY, "PWR",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         
                    
         dc.drawText(150, 178, Graphics.FONT_XTINY, "HR",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        
                    
         
		 if (cad !=null) {                  
         	dc.drawText(60, 150, Graphics.FONT_NUMBER_MILD, ""+cad.format("%3.0f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                               
             }    
             
         if (acad !=null) {
         	dc.drawText(123, 140, Graphics.FONT_SYSTEM_SMALL, ""+acad.format("%3.0f"),
                Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER); 
          
         }
		
		
		dc.drawText(60, 98, Graphics.FONT_NUMBER_MILD, ""+pwr,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER); 
               
                    
        dc.drawText(155, 220, Graphics.FONT_NUMBER_MILD, ""+hr,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        
		dc.drawText(123, 8, Graphics.FONT_SYSTEM_SMALL, ""+timer,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        
        
        if (navState){
 			var tempETTAh;
 			var tempETTAm;
 			//Sys.println("ETA:"+navETTA);
 			var hh = (navETTA / 3600).toNumber();
			var mm = ((navETTA / 60) % 60);
		
 			
 			tempETTAh =hh; 
			if (mm<10) { tempETTAm ="0"+mm;}
			else {tempETTAm =mm; }
			//Sys.println(tempETTAh+":"+tempETTAm);     
        	 
                if (backgrWhite==false){
                	dc.setColor(0xff5555, Graphics.COLOR_TRANSPARENT);  
                }
                else {
                	dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);    
                }
        	dc.drawText(40, 8, Graphics.FONT_SYSTEM_SMALL, tempETTAh+":"+tempETTAm,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        	dc.setColor(fontColor, fontColorBackground);
        
        	var formatierung="%4.1f";
         	if (dst != null){ 
         		if (dst>=100.0) {formatierung="%3.0f";}
         		
         		dc.drawText(185, 285, Graphics.FONT_SYSTEM_MEDIUM, ""+dst.format(formatierung),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                
                if (backgrWhite==false){
                	dc.setColor(0xff5555, Graphics.COLOR_TRANSPARENT);  
                }
                else {
                	dc.setColor(Graphics.COLOR_DK_RED, Graphics.COLOR_TRANSPARENT);    
                }
                dc.drawText(225, 300, Graphics.FONT_SYSTEM_MEDIUM, ""+(navDistance/1000).format("%3.1f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);    
            	dc.setColor(fontColor, fontColorBackground);
            }
        
        }
        else{
        	var formatierung="%4.1f";
        	if (dst != null){ 
         		if (dst>=100.0) {formatierung="%3.0f";}
         		dc.drawText(215, 295, Graphics.FONT_NUMBER_MILD, ""+dst.format(formatierung),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            }
        
        }
        
                    
        dc.drawText(225, 8, Graphics.FONT_SYSTEM_SMALL, ""+timeNow,
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);            
                    
        
         if (counter_disp_grade_vspd<=5){
           dc.drawText(123, 285, Graphics.FONT_SYSTEM_SMALL, ""+grade.format("%2.0f")+"%",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
           dc.drawText(123, 300, Graphics.FONT_SYSTEM_XTINY, "GRADE",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         }
         else {
           dc.drawText(123, 285, Graphics.FONT_SYSTEM_SMALL, ""+(vSpeed.abs()).format("%4.0f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
           dc.drawText(123, 300, Graphics.FONT_SYSTEM_XTINY, "VSPD",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);          
           drawArrow(dc); 
           if (counter_disp_grade_vspd>10){
         		counter_disp_grade_vspd=0;
         	}
         }
         
                    
         
        
         dc.drawText(90, 220, Graphics.FONT_NUMBER_MILD, ""+spd.format("%3.1f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);   
                    
         dc.drawText(20, 220, Graphics.FONT_SYSTEM_SMALL, ""+aspd.format("%3.1f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);              
                    
                    
       //  if (batterie != null){
       //   dc.drawText(100, 256, Graphics.FONT_XTINY, ""+batterie.format("%3.0f")+"%",
       //             Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER); 
       //  }             
         
              
        
         
          if (hgt != null){
		 	 dc.drawText(45, 295, Graphics.FONT_NUMBER_MILD, ""+hgt.format("%3.0f"),
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
            
          }    
          
          
          dc.drawText(40, 315, Graphics.FONT_XTINY, "ALT",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                    
          dc.drawText(200, 315, Graphics.FONT_XTINY, "DST",
                    Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);         
                   
        //PowerBalance
        // powerBalance=47; // DELETE
        
         var powerBal3sAvg=0;
       if(powerBalance !=0 && powerBalance != null){
           
          powBalAvg[counterPowBal]=powerBalance;
          counterPowBal++;
          if(counterPowBal==3) {counterPowBal=0;}
          
          
          powerBal3sAvg=(powBalAvg[0]+powBalAvg[1]+powBalAvg[2])/3;
             
          
           dc.drawLine (150,86,230,86);
		   dc.drawLine (150,87,230,87);
		   
		   dc.drawLine (190,81,190,86);
		   dc.drawLine (191,81,191,86);
		
		   
		 
           var balanceDelta=powerBal3sAvg-(50-bal_pwr_range);
           if (balanceDelta <0) {balanceDelta=0;}
           if (balanceDelta >bal_pwr_range*2) {balanceDelta=bal_pwr_range*2;}
           
          
            dc.drawText(151+balanceDelta*80/(bal_pwr_range*2),110, Graphics.FONT_SYSTEM_SMALL, powerBal3sAvg+"%",
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
          	dc.drawBitmap(144+balanceDelta*80/(bal_pwr_range*2),88,pfeil2[0]);
         }
         
         if (powerActual.getTorqueEffectivenessPedalSmoothness() != null) {
         	dc.drawText(225,158, Graphics.FONT_XTINY, "EFF L/R",
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         	
         	dc.drawText(210,140, Graphics.FONT_SYSTEM_SMALL, ""+torqueEffectL.format("%3.0f")+"%/"+torqueEffectR.format("%3.0f")+"%",
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
         }
        
        // delete
     /*   dc.drawText(210,140, Graphics.FONT_SYSTEM_SMALL, "88%/86%",
        			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
       			
        			dc.drawText(225,158, Graphics.FONT_XTINY, "EFF L/R",
          			Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
     */    // delete
		
         drawPower(dc,Graphics.COLOR_LT_GRAY);
          
          drawChart(dc,143,220,100,1,0,Graphics.COLOR_LT_GRAY);
          drawChart(dc,143,220,50+100/(2.05*hr_range)*hr_delta,1,0,col_for_hr);
          drawChart(dc,103,220,100,0,-1, Graphics.COLOR_LT_GRAY);
          drawChart(dc,103,220,50+100/(2.05*spd_range)*spd_delta,0,-1, Graphics.COLOR_RED);
          
          dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
        
          
       
		//horizontal
		dc.drawLine (0,17,246,17);
		dc.drawLine (0,120,246,120);
		dc.drawLine (0,170,246,170);
		dc.drawLine (0,272,246,272);
		
		
		
	
		dc.drawLine (37,220,54,220);
		dc.drawLine (37,221,54,221);
		dc.drawLine (193,220,210,220);
		dc.drawLine (193,221,210,221);
		
		// vertical 1
		dc.drawLine (123,170,123,272);
		dc.drawLine (88,272,88,322);
		dc.drawLine (158,272,158,322);
	
		dc.drawLine (123,25,123,40);
		dc.drawLine (124,25,124,40);
		
		
		

		
		
		//pointer	
		 drawPointer(dc);
		
		
		drawBat(dc,batterie);
      //  View.onUpdate(dc);
       
	
       
    }



function onTimerStart(){
	activityStarted=true;
}

function drawChart(dc,x,y,level,right,direction,col){
		var start;
		var end;
		
		if (right==0){
			start=135;
			end=225;
			start = start + (90 * (100-level)/100);
		}
		else{
			start=45;
			end=315;
		    if (level<50){
		    	start= end + 90 * level/100;
		    }
		    else {
		    	start= start - 90 + (90 * level/100);
		    }
		}
		
		  dc.setColor(col, Graphics.COLOR_WHITE);	
		  dc.drawArc(x,y,55, direction, end ,start);
		  dc.drawArc(x,y,56, direction, end,start);
		  dc.drawArc(x,y,57, direction, end,start);
		  dc.drawArc(x,y,58, direction, end,start);
		  dc.drawArc(x,y,59, direction, end,start);
		  dc.drawArc(x,y,60, direction, end,start);
		  dc.drawArc(x,y,61, direction, end,start);
		  dc.drawArc(x,y,62, direction, end,start);
		  dc.drawArc(x,y,63, direction, end,start);
		 // dc.drawArc(x,y,54, direction, end,start);
		//  dc.drawArc(x,y,53, direction, end,start);
          

	}
	
	function drawPower(dc,col){
		var start;
		var end;
		
	
			start=112; // 12 o'clock is 90; 3 o'clock is 0 degree
			end=68;
		   
		
		
		  var x1=0;
		  var y1=0;
		  var delta_y1=0;
		  var delta_y2=0;
		  var pfeilIndex=0;
		  if (backgrWhite==false) {pfeilIndex=1;}
		  
		  if (pwr<np-pwr_range) {
		  	x1=0;	
		  	if (backgrWhite) {pfeilIndex=6;}
		  	else {pfeilIndex=7;}
		  	delta_y2=8;
		  	}
		  else if (pwr>np+pwr_range) {
		  			x1=216;
		  			if (backgrWhite) {pfeilIndex=2;}
		  			else {pfeilIndex=3;}
		  			delta_y2=8;
		  		}
		  		else {
		  			x1= 108 + ((pwr-np)*(216.0/(2*pwr_range))); 
		  			 }
		  
		  
		  delta_y1=((pwr-np)*(216.0/(2*pwr_range))).abs();
		  if (delta_y1>108) {delta_y1=108;}
		  
		  dc.drawBitmap(10+x1,40+(delta_y1/8)+delta_y2,pfeil2[pfeilIndex]);
		
		
		  dc.setColor(col, Graphics.COLOR_WHITE);	
		  drawPowerArc(dc, start , end);
		  
			  
		  //draw zones
		  var power_start = np + pwr_range;
		  var i=power_level.size()-1;
		  while (power_start < power_level[i]) {
		    	i--;
		    	dc.setColor(colors_pwr[i], Graphics.COLOR_WHITE);
		    	
		  	}	
		  drawPowerArc(dc, 112 ,68);
		  
		  
		  while (i>0) {
		   i--;
		   dc.setColor(colors_pwr[i], Graphics.COLOR_WHITE);
		   if (power_level[i]<np-pwr_range){break;}
		   drawPowerArc(dc, 112 ,(112-(power_level[i] - (np-100.0))*(44.0/(2*pwr_range))).toNumber());   
		 //  Sys.println(112-((power_level[i] - (np-100.0))*(44.0/(2*pwr_range))).toNumber());
		  }
		  
  dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_WHITE );	

	}


function drawPowerArc(dc, start, end){
		  var x=123;
		  var y=317;
		  var radius=285;
		  dc.setPenWidth(11);
		  dc.drawArc(x,y,radius, Graphics.ARC_CLOCKWISE, start, end);
	/*
		  dc.drawArc(x,y,radius+1, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+2, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+3, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+4, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+5, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+6, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+7, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+8, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+9, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+10, Graphics.ARC_CLOCKWISE, start, end);
		  dc.drawArc(x,y,radius+11, Graphics.ARC_CLOCKWISE, start, end);
		*/
		 
	 	 dc.setPenWidth(1);
  }


function calcGradevSpeed(curSpd, curAlt){
		if (alt_over_time[counter2] == null || alt_over_time[counter2]==0.0) {
			for (var i = 0; i < speed_over_time.size(); ++i) {
			speed_over_time[i] = curSpd;
			}
			
			for (var i = 0; i < alt_over_time.size(); ++i) {
			alt_over_time[i] = curAlt;
			}
		}
       /*  var temp;
         for (var i = 0; i < alt_over_time.size(); ++i) {
			temp=temp + " "+i+" "+alt_over_time[i];
			}
    	 Sys.println(temp);
    	 var temp2;
         for (var i = 0; i < speed_over_time.size(); ++i) {
			temp2=temp2 + " "+i+" "+speed_over_time[i];
			}
    	 Sys.println(temp2);
    	 */ 
    	counter2 ++;
        speed_over_time[counter2-1]=curSpd;
       	alt_over_time[counter2-1]=curAlt;
        	
        try{
        //	alt_over_time[(counter2+rollingAveragePeriod5-2) % rollingAveragePeriod5]=0.5 * (0.5*alt_over_time[(counter2+rollingAveragePeriod5-3) % rollingAveragePeriod5]+alt_over_time[(counter2+rollingAveragePeriod5-2) % rollingAveragePeriod5]+0.5 *alt_over_time[(counter2+rollingAveragePeriod5-1) % rollingAveragePeriod5]);
        }
        catch (ev){
        }
       try
       {
         altgain = alt_over_time[counter2-1] - alt_over_time[counter2 % rollingAveragePeriod5];
         for (var i = 0; i < rollingAveragePeriod5; i += 1) {     
         	distance = distance+ speed_over_time[(counter2 + i) % rollingAveragePeriod5];
 		 }      
       }
       catch (ed)
       {
         altgain  = 0.0;
        // distance = 0;
         
       }
       
       if (distance !=0){     
       		grade= (grade + (100 * (altgain/ distance)))/2;
       	}
       else {
       		grade=0;
       	}
   			
   			vSpeed=(vSpeed + 3600 * altgain / rollingAveragePeriod5)/2;
   			vSpeed= (Mat.round(vSpeed / 10))* 10;
       		
       		distance=0;
       		altgain=0;
       		
       if (counter2 == rollingAveragePeriod5) {
       		counter2=0;
       }
    
}

function calcNP(currentPower)
    {
     var value_picked = 0;  
     if (activityStarted){
     
        
       
	    		        
        	if (poulationCount == rollingAveragePeriod)
            {                    
            	poulationCount = 0;
            }
        	   	
        	rollingAverageArray[poulationCount] = 	currentPower;            
	    	               
            if (initialCount >= rollingAveragePeriod)
            {
            	var totalMean = 0;
             	
             	for(var i = 0; i <= rollingAverageArray.size() - 1 ; i ++)
				{
				     totalMean = totalMean + rollingAverageArray[i];
				}
				
				var rollingAveragePower = totalMean / rollingAveragePeriod;   
				
					
				var wattsToThe4 = Math.pow(rollingAveragePower, 4);
				wattsToThe4Total = wattsToThe4Total + wattsToThe4;
				normalisedCount = normalisedCount + 1;
				var avr2 = wattsToThe4Total/normalisedCount;			
                var normalisedPower = Math.pow(avr2, (1.0 / 4.0));
                
                
                value_picked = normalisedPower;
           }
            else
            {
            	value_picked = 0; 
            }
            
            poulationCount = poulationCount + 1;
            initialCount = initialCount + 1;
            
        }
                 
        return value_picked;
     }

 function calc5sPwr(currentPower)
    {
        var value_picked = null;   
              
        	if (poulationCount5 == rollingAveragePeriod5)
            {                    
            	poulationCount5 = 0;
            }
        	   	
        	rollingAverageArray5[poulationCount5] = currentPower;            
	    	               
            if (initialCount5 >= rollingAveragePeriod5)
            {
            	var totalMean = 0;
             	
             	for(var i = 0; i <= rollingAverageArray5.size() - 1 ; i ++)
				{
					totalMean = totalMean + rollingAverageArray5[i];
				}
				var rollingAveragePower5 = totalMean / rollingAveragePeriod5;                 
                value_picked = rollingAveragePower5;
               		             
				
            }
            else
            {
            	value_picked = 0; 
            }
            
            poulationCount5 = poulationCount5 + 1;
            initialCount5 = initialCount5 + 1;
  
        return value_picked;
     }






function drawBat(context,level){
		context.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
		context.drawRectangle(103,307,40,14);
		//level=0.08;
		if (level<10.0){ 
			context.setColor(Graphics.COLOR_RED, Graphics.COLOR_WHITE);
			context.fillRectangle(105,309,4,10);
			context.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_WHITE);
			}
			
		
		if (level<20.0 && level >=10.0){ context.fillRectangle(105,309,8,10);}
		if (level<30.0 && level >=20.0){ context.fillRectangle(105,309,12,10);}
		if (level<40.0 && level >=30.0){ context.fillRectangle(105,309,16,10);}
		if (level<50.0 && level >=40.0){ context.fillRectangle(105,309,20,10);}
		if (level<60.0 && level >=50.0){ context.fillRectangle(105,309,24,10);}
		if (level<70.0 && level >=60.0){ context.fillRectangle(105,309,27,10);}
		if (level<80.0 && level >=70.0){ context.fillRectangle(105,309,30,10);}
		if (level<90.0 && level >=80.0){ context.fillRectangle(105,309,33,10);}
		if (level>=90.0){ context.fillRectangle(105,309,36,10);}

		
		
		context.drawRectangle(143,311,4,6);

	}

	function drawArrow(context){
		if (vSpeed>0){
			if (backgrWhite) {context.drawBitmap(143,279,pfeil2[0]);}
			else {context.drawBitmap(143,279,pfeil2[1]);}
		}
		if (vSpeed<0){
			if (backgrWhite) {context.drawBitmap(143,279,pfeil2[4]);}
			else {context.drawBitmap(143,279,pfeil2[5]);}
		}
		
	}


function drawPointer(dc){
	var pi2=2*3.14159;	
	var x=6;
	var y=4;
	var adjHdg=0.0;
	var adjBear=0.0;
	var direction=0.0;
	var navDir=0.0;
	
	if (hdg<0){adjHdg=hdg+pi2;}
	else {adjHdg=hdg;}
	
//	Sys.println("Heading: "+360.0*adjHdg/pi2);
	if (navState){
		
		
		if (bear<0){adjBear=bear+pi2;}
		else{adjBear=bear;}
		
		navDir=adjBear-adjHdg;
		if (navDir<0){navDir=navDir+pi2;}
		
		
		if (navDir>pi2*15/16 || navDir<=pi2/16) {dc.drawBitmap(x,y,pfeil_r[0]);}
		if (navDir>pi2/16   && navDir<=pi2*3/16) {dc.drawBitmap(x,y,pfeil_r[1]);}
		if (navDir>pi2*3/16 && navDir<=pi2*5/16) {dc.drawBitmap(x,y,pfeil_r[2]);}
		if (navDir>pi2*5/16 && navDir<=pi2*7/16) {dc.drawBitmap(x,y,pfeil_r[3]);}
		if (navDir>pi2*7/16 && navDir<=pi2*9/16) {dc.drawBitmap(x,y,pfeil_r[4]);}
		if (navDir>pi2*9/16 && navDir<=pi2*11/16) {dc.drawBitmap(x,y,pfeil_r[5]);}
		if (navDir>pi2*11/16 && navDir<=pi2*13/16) {dc.drawBitmap(x,y,pfeil_r[6]);}
		if (navDir>pi2*13/16 && navDir<=pi2*15/16) {dc.drawBitmap(x,y,pfeil_r[7]);}
	
	}
	
	else {
		
		direction=pi2 - adjHdg;
		if (direction>pi2*15.0/16.0 || direction<=pi2/16.0) {dc.drawBitmap(x,y,pfeil[0]);}
		if (direction>pi2/16.0   && direction<=pi2*3/16.0) {dc.drawBitmap(x,y,pfeil[1]);}
		if (direction>pi2*3.0/16.0 && direction<=pi2*5/16.0) {dc.drawBitmap(x,y,pfeil[2]);}
		if (direction>pi2*5.0/16.0 && direction<=pi2*7/16.0) {dc.drawBitmap(x,y,pfeil[3]);}
		if (direction>pi2*7.0/16.0 && direction<=pi2*9/16.0) {dc.drawBitmap(x,y,pfeil[4]);}
		if (direction>pi2*9.0/16.0 && direction<=pi2*11/16.0) {dc.drawBitmap(x,y,pfeil[5]);}
		if (direction>pi2*11.0/16.0 && direction<=pi2*13/16.0) {dc.drawBitmap(x,y,pfeil[6]);}
		if (direction>pi2*13.0/16.0 && direction<=pi2*15/16.0) {dc.drawBitmap(x,y,pfeil[7]);}
	//dc.drawCircle(x+5,y+5,7);
	//dc.drawCircle(x+5,y+5,8);
	}
		

	}

}
