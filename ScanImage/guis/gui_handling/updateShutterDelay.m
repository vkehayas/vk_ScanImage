function updateShutterDelay
%Updates the vector witht he frame nad strip after which to open the shutter...

global state

ns=state.internal.numberOfStripes;
lpf=state.acq.linesPerFrame;
mspl=1000*state.acq.msPerLine;
nf=state.acq.numberOfFrames;

mspstripe=mspl*lpf/ns;
stripeNumber=state.shutter.shutterDelay/mspstripe;
frameNumber=floor(stripeNumber/ns)+1;
stripeInFrame=ceil(rem(stripeNumber,ns))-1;

if stripeInFrame > 2  & frameNumber > 1 %Correct for inherent delay....
    stripeInFrame=stripeInFrame-1;
elseif stripeInFrame < 2 & frameNumber > 1
    stripeInFrame=ns-1;
    frameNumber=frameNumber-1;
elseif stripeInFrame < 2 & frameNumber == 1
    stripeInFrame=stripeInFrame+1;
end

state.shutter.shutterDelayVector=([frameNumber stripeInFrame]);
