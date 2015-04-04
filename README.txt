Running constant_loop.m will start the GUI. 
This GUI is currently incomplete but has most functionality. 4/3/2015

TABLE OF CONTENTS =========================================================
    - Running the GUI
    - Command Types
    -

Running the GUI ===========================================================
    1) Plug in everything on the CR and MR. The CR needs ~30s for the
    Raspberry Pi to fully initialize and start running its script. If the
    CR XBee and CR Arduino are not connected to the RPi then the script 
    will crash and theoretically keep trying to restart itself (though this
    functionality has not been verified). The switch on the MR Arduino XBee
    shield must be set to UART not DLINE in order for it to properly
    receive and relay data between the two MR XBee's.

    2) Run 'constant_loop.m'. This is a function that initializes
    everything on the ground station outside of the main GUI function. It
    runs in a constant loop that is checking to see if the "ABORT MISSION"
    button on the GUI was pressed. As of 4/3/2015 the maximum mission
    duration was fixed at 1000 seconds but this will be changed when full
    system testing is being done as the actual CR mission will likely be 
    closer to 90 minutes. A timer object is also started that calls the 
    'request_status_Callback.m' function which periodically checks if
    communications are present between all of the systems. The timer object
    is stopped when the constant loop is exited.

    3) Select the radio button on the GUI for the command you would like to
    send and fill in a value to the associated text box (if applicable).
    The textbox callbacks within 'GS_gui.m' are (generally) set to limit
    the input to reasonable values but the user must still be careful in
    sending commands like driving and spooling out tether because the CR
    and MR are not smart enough to not cause themselves harm.

Command Types =============================================================
    The basic command structure starts with a '$' delimeter and a newline
    EOL character. The shortest string that is expected to be sent is 4 
    characters whereas the longest is ~90,000 for an image

   - RAPPELLING
        There are three different types of rappelling commands: down, up, 
        and "return". Down and up are self-explanatory and they are done by
        commanding a distance to rappel. The "return" command causes the CR
        to switch to its front-wheel encoders and then the MR will retract
        the CR back to the top of the cave/pipe.

        The rappelling commands are structured as follows:
            For Down/Up: $R0[+/-][zero-padded distance in cm (3 char)][\n]
            for a total of 8 characters. (e.g. $R0-073[\n])
            For "Auto-Rappel": $RA[\n] for a total of 4 characters
            For "Return": $RU[\n] for a total of 4 characters
        The rappelling command acknowledgements are structured as follows:
            [THIS SHOULD INCLUDE MORE INFORMATION AS THE CR DEPTH NEEDS TO 
            ALSO BE UPDATED WITH THE ACKNOWLEDGEMENT]
            $R[P/F][\n] for a total of 4 characters where P=PASS & F=FAIL

    - DRIVING
        There are four different types of driving commands: forward, back,
        left-, and right-handed turns. The forward and backward driving are
        the only two options that are required from the problem definition
        but it has been decided that being able to turn will also be
        necessary to execute the mission. During forward and backward
        driving the CR will be tracking its distance travelled using
        odometry so that it will drive the user-commanded distance. The 
        user commands a turn angle for left- and right-handed turns and the
        CR again uses odometry to approximately determine how far it has
        turned doing a skid turn (where the back wheels do not turn). It
        should be noted that there is no requirement to turn accurately.
        
        The driving commands are structured as follows:
            $D[F/B/L/R][zero-padded distance/angle in cm/deg (3 char)][\n]
            for a total of 7 characters. (e.g. $DL005[\n])
        The driving command acknowledgements are structured as follows:
            [THIS SHOULD INCLUDE MORE INFORMATION AS THE CR DISTANCE NEEDS  
            TO ALSO BE UPDATED WITH THE ACKNOWLEDGEMENT]
            $D[P/F][\n] for a total of 4 characters where P=PASS & F=FAIL

    - IMAGING
        Each image capture command that is sent by the GS is accompanied by
        pan and tilt angles to hold the servos at during the image capture.
        The CR will then capture an image, save it locally, compress the 
        image, then encode it as a text string to send via the XBee radios.
        The GS must then keep its COM port open until it detects the
        'ENDOFFILE' text delimeter at the end of the image string. There is
        also a newline character attached at the end of the image string
        but due to the method of reading text from the serial port buffer,
        the GS is unable to detect this newline character. The image string
        must then be decoded on the GS computer using a python script in
        order to be displayed to the user.
            NOTE: The number of characters that should have been received
                  was later added as additional information that the GS
                  can parse for troubleshooting. If the number of received 
                  characters does not match this value the GS currently
                  only warns the user and still attempts to decode the
                  image (this sometimes works even with missing characters)
        
        The imaging commands are structured as follows:
            $I[+/- (pan angle sign)][zero-padded pan angle in deg (2 ...
            char)][zero-padded tilt angle in deg (2 char)][\n] for a total
            of 8 characters. (e.g. $I-0872[\n])
        The imaging command acknowledgements are structured as follows:
            $I[IMAGE STRING TEXT (~90,000 char)][nchars][ENDOFFILE][\n] 
            where 'nchars' is the integer number of characters in the full
            image string text.
    
    - SPOOLING
        This gives functionality to the GS to spool out (or in) an 
        approximate length of tether. The MR Arduino only uses feedback
        from the encoder on the winch stepper motor to calculate arclength.
        The speed for reeling in is set to be much slower than reeling out
        because there are situations when returning that the stepper motor
        could get stalled (e.g. if the CR was caught on something) so it is
        just safer to go slower.
    
        The spooling commands are structured as follows:
            $AO[+/- zero-padded spool distance in cm (3 char)][\n] for a
            total of 8 characters. (e.g. $AO+045[\n])
        The spooling command acknowledgements are structured as follows:
            $A[P/F][\n] for a total of 4 characters
    
    - DEPLOYING
        
    
    - RETURNING
        
    

    - STATUS REQUEST
        A timer object is set up when creating the GS_GUI that is started
        at the beginning of the 'constant_loop'. The timer fires with a
        period of the 'timer_period' variable set in the 'GS_gui_OutputFcn'
        that will likely be 30 seconds but is subject to change. When the 
        timer "fires" it executes the 'request_status_Callback' function
        which sends a status request string to the MR and CR. The MR will 
        respond with its battery voltage in mV and the CR will respond with
        its battery voltage in mV as well as its depth and distance
        travelled in cm. The battery voltages are then compared to a
        lookup table of their discharge curves to determine the remaining
        battery capacities.
        
        The status requests are structured as follows:
            $SR[\n] for a total of 4 characters
        The status request acknowledgements are structured as follows:
            From the MR: $SMB[zero-padded MR battery voltage in mV ...
            (6 char)][\n] for a total of 11 characters
                (e.g. $SMB014622[\n])
            From the CR: $SCB[zero-padded CR battery voltage in mV ...
            (6 char)][\n] for a total of 11 characters
                (e.g. $SCB014795[\n])
            AND $SCP[zero-padded CR depth in cm (3 char)][zero-padded ...
            CR distance travelled in cm (4 char)][\n] for a total of 12
            characters
                (e.g. $SCP3620021[\n])
===========================================================================