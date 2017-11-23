function MP285GetStatus()

global state

MP285Flush;
fwrite(state.motor.serialPortHandle,'s');
fwrite(state.motor.serialPortHandle,13);

status = MP285ReadAnswer;

disp(['FLAGS: ' num2str(dec2bin(status(1)))]);
disp(['UDIRX: ' num2str(status(2))]);
disp(['UDIRY: ' num2str(status(3))]);
disp(['UDIRZ: ' num2str(status(4))]);

disp(['ROE_VARI: ' word2str(status(5:6))]);
disp(['UOFFSET: ' word2str(status(7:8))]);
disp(['URANGE: ' word2str(status(9:10))]);
disp(['PULSE: ' word2str(status(11:12))]);
disp(['USPEED: ' word2str(status(13:14))]);

disp(['INDEVICE: ' num2str(status(15))]);
disp(['FLAGS_2: ' num2str(dec2bin(status(16)))]);

disp(['JUMPSPD: ' word2str(status(17:18))]);
disp(['HIGHSPD: ' word2str(status(19:20))]);
disp(['DEAD: ' word2str(status(21:22))]);
disp(['WATCH_DOG: ' word2str(status(23:24))]);
disp(['STEP_DIV: ' word2str(status(25:26))]);
disp(['STEP_MUL: ' word2str(status(27:28))]);

%I'm not sure what happens to byte #28

%Handle the Remote Speed value. Unlike all the rest...it's big-endian.
speedval = 2^8*status(30) + status(29);
if speedval >= 2^15
    disp('XSPEED RES: HIGH');
    speedval = speedval - 2^15;
else
    disp('XSPEED RES: LOW');
end
disp(['XSPEED: ' num2str(speedval)]);

disp(['VERSION: ' word2str(status(31:32))]);


function outstr = word2str(bytePair)

val = 2^8*bytePair(2) + bytePair(1); %value comes in little-endian
outstr = num2str(val);







