using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time.Gregorian as Calendar;
using Toybox.SensorHistory as Sensor;
using Toybox.ActivityMonitor;

class WatchView extends WatchUi.WatchFace {

 	var showSeconds;
 	var showColon;
 	var dateFormat = 0;
 	var width_screen;
	var height_screen;
	var wkNo = 0;
	var day = 1009;
	var batteryLimit = 30;
	var showHeart = false;
 	
    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    function onShow() {
    }
    
    function onPowerBudgetExceeded(powerInfo){
		System.println("Exceeded " + powerInfo.executionTimeAverage + " > " + powerInfo.executionTimeLimit);
	}    
    
    function onPartialUpdate(dc) {
    	showSeconds = false;//Application.getApp().getProperty("showSeconds"); 
        
        if(showSeconds){
        	dc.setClip(width_screen - 90, height_screen/2 - 50, 100, 100);
		    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    		dc.clear();
        	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    
	    	var clockTime = System.getClockTime();
	        
	    	var secs = ":" + clockTime.sec.format("%02d");
	        dc.drawText(width_screen - 50, height_screen/2, Gfx.FONT_NUMBER_THAI_HOT, secs, Gfx.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
	        dc.clearClip();
	       }
	       
	    if(showHeart){
		    var heartNow = Activity.getActivityInfo().currentHeartRate;
					
			dc.setClip(width_screen /2 + 40, height_screen /2 +50, 40, 35);
			dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
	    	dc.clear();
	        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	    
	    	dc.drawText(width_screen/2 + 60, height_screen/2 + 60, Gfx.FONT_SYSTEM_XTINY, "| " + getHeartRate(), Gfx.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
	    	
	    	dc.clearClip();
	    }
	    
	}    	
    
    function onUpdate(dc) {
        showSeconds = false;//Application.getApp().getProperty("showSeconds"); 
        showColon = Application.getApp().getProperty("showColon");
        showHeart = Application.getApp().getProperty("showHeart");
        dateFormat = Application.getApp().getProperty("dateFormat");
        batteryLimit = Application.getApp().getProperty("batteryLimit");
        
		var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        width_screen = dc.getWidth();
		height_screen = dc.getHeight();
			
		dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
    
        var hours = clockTime.hour;
        var timeString;
        
     
		if(showColon){
   			timeFormat = "$1$:$2$";
   		}
   		else {
   			timeFormat = "$1$$2$";
   		}
   		
    	hours = hours.format("%02d");
		timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
		
    	var battery = Sys.getSystemStats().battery;
               	
        var info = Calendar.info(Time.now(), Time.FORMAT_LONG);
        var infoShort = Calendar.info(Time.now(), Time.FORMAT_SHORT);
        var dateStr;
        
        if(dateFormat == 0){
        	dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.day, info.month]);
        }
        else if(dateFormat == 1){
        	dateStr = Lang.format("$1$.$2$.$3$", [info.year, infoShort.month, info.day]);
        }
        else if(dateFormat == 2){
        	dateStr = Lang.format("$1$ $2$/$3$", [info.day_of_week, infoShort.day, infoShort.month]);
        }
      	else if(dateFormat == 3){
        	dateStr = Lang.format("$1$ $2$/$3$", [info.day_of_week, infoShort.month, infoShort.day]);
       	}
       	else{
       		dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.day, info.month]);
       	}
       	
       	var secOffSet = 0;
        
        if(showSeconds) {
        	secOffSet = 42;
        	if(!showColon){
        		secOffSet = 37;
        	}
        	var secs = ":" + clockTime.sec.format("%02d");
        	dc.drawText(width_screen - 50, height_screen/2, Gfx.FONT_NUMBER_THAI_HOT, secs, Gfx.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        }
        
       	dc.drawText(width_screen/2 - secOffSet, height_screen/2, Gfx.FONT_NUMBER_THAI_HOT, timeString, Gfx.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		
		
		dc.drawText(width_screen/2, height_screen/2 - 60, Gfx.FONT_SMALL, dateStr, Gfx.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
		
		var shortInfo = Calendar.info(Time.now(), Time.FORMAT_SHORT);
		
		if(shortInfo.day != day){
			wkNo = iso_week_number(shortInfo.year, shortInfo.month, shortInfo.day);
		}
	
		var lowerLine = "wk" + wkNo + " | ";
		dc.drawText(width_screen/2 - 25, height_screen/2 + 60, Gfx.FONT_SYSTEM_XTINY, lowerLine, Gfx.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        
        if(battery <= batteryLimit){
        	
        	dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_BLACK);
        }
        
        var lowerLine1 =  Lang.format("$1$%", [battery.format("%2d")]);
        dc.drawText(width_screen/2 + 20, height_screen/2 + 60, Gfx.FONT_SYSTEM_XTINY, lowerLine1, Gfx.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
     	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
     	
		var offset = 30;
		
     	if(showHeart){
			dc.drawText(width_screen/2 + (30 + offset), height_screen/2 + 60, Gfx.FONT_SYSTEM_XTINY, "| " + getHeartRate() , Gfx.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
		
		}
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
    
    function julian_day(year, month, day)
	{
	    var a = (14 - month) / 12;
	    var y = (year + 4800 - a);
	    var m = (month + 12 * a - 3);
	    return day + ((153 * m + 2) / 5) + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045;
	}

	function is_leap_year(year)
	{
	    if (year % 4 != 0) {
	        return false;
	    }
	    else if (year % 100 != 0) {
	        return true;
	    }
	    else if (year % 400 == 0) {
	        return true;
	    }
	
	    return false;
	}
	
	function iso_week_number(year, month, day)
	{
	    var first_day_of_year = julian_day(year, 1, 1);
	    var given_day_of_year = julian_day(year, month, day);
	
	    var day_of_week = (first_day_of_year + 3) % 7; // days past thursday
	    var week_of_year = (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
	
	    // week is at end of this year or the beginning of next year
	    if (week_of_year == 53) {
	
	        if (day_of_week == 6) {
	            return week_of_year;
	        }
	        else if (day_of_week == 5 && is_leap_year(year)) {
	            return week_of_year;
	        }
	        else {
	            return 1;
	        }
	    }
	
	    // week is in previous year, try again under that year
	    else if (week_of_year == 0) {
	        first_day_of_year = julian_day(year - 1, 1, 1);
	
	        day_of_week = (first_day_of_year + 3) % 7;
	
	        return (given_day_of_year - first_day_of_year + day_of_week + 4) / 7;
	    }
	
	    // any old week of the year
	    else {
	        return week_of_year;
	    }
	}
	
	        	
 function getHeartRate()     {
  var ret = "--";
  var hr = Activity.getActivityInfo().currentHeartRate;
  if(hr != null) {ret = hr.toString();}
   else {
    var hrI = ActivityMonitor.getHeartRateHistory(1, true);
    var hrs = hrI.next().heartRate;
    if(hrs != null && hrs != ActivityMonitor.INVALID_HR_SAMPLE) {ret = hrs.toString();}
        }  
   return ret;  
                            }

}
