function param = radiofskreceiver_init(message, validationNum)

%% Modulation parameters

param.ModOrder = 4;
param.BitInput = 1;
param.FreqSep = 500;
param.SampPerSym = 50;
param.SymRate = 400;
param.TSymRate = 1/param.SymRate;
param.FS = param.SymRate * param.SampPerSym * 100;

%% Message parameters
param.BarkerCode      = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1];     % Bipolar Barker Code
param.BarkerLength    = length(param.BarkerCode);
param.HeaderLength    = param.BarkerLength * log2(param.ModOrder) * 2;      % Duplicate 2 Barker codes to be as a header
param.Message         = message;
param.MessageLength   = length(param.Message) + 5;                          % 'Just checking 000\n'...
param.NumberOfMessage = 10 * log2(param.ModOrder);                          % Number of messages in a frame
param.ValidationNum   = validationNum;                                                  % Number of messages to validate the node
param.PayloadLength   = param.NumberOfMessage * param.MessageLength * 7;    % 7 bits per characters
param.FrameSize       = (param.HeaderLength + param.PayloadLength) ...
    / log2(param.ModOrder);                                    % Frame size in symbols
param.FrameTime       = param.TSymRate * param.FrameSize;

%% AGC parameters
param.DesiredPower                  = 1;            % AGC desired output power (in watts)
param.AveragingLength               = 200;           % AGC averaging length
param.MaxPowerGain                  = 60;           % AGC maximum output power gain

%% Modulated Barker Code 
ubc = ((param.BarkerCode + 1) / 2)';
temp = (repmat(ubc,1,log2(param.ModOrder)*2))';
header = temp(:);
FSKModulator  = comm.FSKModulator( ...
    'ModulationOrder',              param.ModOrder, ...
    'BitInput',                     param.BitInput, ...
    'FrequencySeparation',          param.FreqSep, ...
    'SamplesPerSymbol',             param.SampPerSym, ...
    'SymbolRate',                   param.SymRate, ...
    'ContinuousPhase',              1);
param.ModulatedHeader = FSKModulator(header);
param.PreambleDetectionThreshold    = 300;

%% Msg to bits
message_mat_bits = dec2bin(double(param.Message));
message_mat_bin = message_mat_bits - '0';   
param.MessageBits = reshape(message_mat_bin', [], 1);

%% Pluto receiver parameters
param.PlutoCenterFrequency      = 433e6;
param.PlutoGain                 = 55    ;
param.PlutoFrontEndSampleRate   = param.FS;
param.PlutoFrameLength          = param.FrameSize * param.SampPerSym;

%% General parameters
param.StopTime  = 500;