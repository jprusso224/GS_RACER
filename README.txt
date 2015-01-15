Running constant_loop.m will start the GUI. 
This GUI is currently incomplete but has some basic functionality.

Command Types =============================================================
   - RAPPELLING
        There are three different types of rappelling commands: down, up, 
        and "return". Down and up are self-explanatory and they are done by
        commanding a distance to rappel. The "return" command causes the CR
        to switch to its front-wheel encoders and then the MR will retract
        the CR back to the top of the cave/pipe.

        The rappelling commands are structured as follows:
            For Down/Up: $R0[+/-][zero-padded distance in cm (3 char)][\n]
            for a total of 8 characters
            For "Return": $RU[\n] for a total of 4 characters

    - DRIVING
        [DRIVING COMMAND DESCRIPTION TEXT HERE]
        
        The driving commands are structured as follows:
            
        The driving command acknowledgements are structured as follows:
            

    - IMAGING
        [IMAGING COMMAND DESCRIPTION TEXT HERE]
        
        The imaging commands are structured as follows:
            
        The imaging command acknowledgements are structured as follows:
            

    - STATUS REQUEST
        [STATUS REQUEST DESCRIPTION TEXT HERE]
        
        The status requests are structured as follows:
            $SR[\n] for a total of 4 characters
        The status request acknowledgements are structured as follows: