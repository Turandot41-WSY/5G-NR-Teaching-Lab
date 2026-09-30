function tests = test_uni01
% Regression contract for the cell-search teaching receiver.
tests = functiontests(localfunctions);
end

function testNoiselessRoundTrip(testCase)
c=uni01_config; t=uni01_tx(c); r=uni01_rx(t.waveform,c.receiver);
verifyFalse(testCase,r.crcError);
verifyEqual(testCase,r.cellID,c.cellID);
verifyEqual(testCase,r.mibBits,t.mibBits);
verifyEqual(testCase,r.systemFrameNumber,c.systemFrameNumber);
verifyEqual(testCase,r.ssbIndex,c.ssbIndex);
end

function testTimingAndFrequencyAreEstimated(testCase)
c=uni01_config; t=uni01_tx(c); delay=137; cfo=23700;
w=[zeros(delay,1);t.waveform;zeros(1024,1)];
w=w.*exp(1i*2*pi*cfo*(0:numel(w)-1)'/t.sampleRate);
r=uni01_rx(w,c.receiver);
verifyFalse(testCase,r.crcError);
verifyEqual(testCase,r.mibBits,t.mibBits);
verifyLessThan(testCase,abs(r.frequencyOffset-cfo),50);
verifyLessThanOrEqual(testCase,abs(r.ssbStartSample-(t.ssbStartSample+delay)),2);
end

function testAllPssIdentities(testCase)
for nid=[321 322 323]
    c=uni01_config; c.cellID=nid; t=uni01_tx(c);
    r=uni01_rx(t.waveform,c.receiver);
    verifyFalse(testCase,r.crcError);
    verifyEqual(testCase,r.cellID,nid);
end
end

function testPssGenerationMatchesSpecification(testCase)
% TS38.211 7.4.2.2.1; validate our independently written recurrence.
x=zeros(127,1); x(1:7)=[0;1;1;0;1;1;1];
for i=1:120, x(i+7)=mod(x(i+4)+x(i),2); end
for n2=0:2
    expected=1-2*x(mod((0:126)'+43*n2,127)+1);
    verifyEqual(testCase,nrPSS(n2),expected);
end
end

function testExperimentSupportExists(testCase)
verifyEqual(testCase,exist('uni01_observe','file'),2);
verifyEqual(testCase,exist('uni01_interval','file'),2);
verifyEqual(testCase,exist('run_uni01','file'),2);
end

function testReceiverImplementationExists(testCase)
verifyEqual(testCase, exist('uni01_config','file'), 2, ...
    'The reproducible Uni-01 configuration has not been implemented.');
verifyEqual(testCase, exist('uni01_tx','file'), 2, ...
    'The standards-based SS/PBCH transmitter has not been implemented.');
verifyEqual(testCase, exist('uni01_rx','file'), 2, ...
    'The practical cell-search receiver has not been implemented.');
end

function testAcceptanceCoversAllAcquiredFields(testCase)
c=uni01_config; t=uni01_tx(c); r=uni01_rx(t.waveform,c.receiver);
verifyTrue(testCase,uni01_accept(r,t));
for field={'ssbIndex','halfFrame','kSsb','systemFrameNumber'}
    wrong=r; wrong.(field{1})=wrong.(field{1})+1;
    verifyFalse(testCase,uni01_accept(wrong,t));
end
end

function testUnsupportedSsbFixtureIsRejected(testCase)
c=uni01_config; c.ssbIndex=4;
verifyError(testCase,@()uni01_tx(c),'uni01:UnsupportedFixture');
end

function testWilsonZeroCountRetainsUncertainty(testCase)
[lo,hi]=uni01_interval(0,40);
verifyEqual(testCase,lo,0,'AbsTol',1e-12);
verifyEqual(testCase,hi,0.0876216011972863,'AbsTol',1e-12);
end
