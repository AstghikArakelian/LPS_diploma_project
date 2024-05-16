function param = radiofsktransmitter_init(message, nummess)

%% Modulation parameters

param.ModOrder = 4;
param.BitInput = 1;    %true: The input values must be a column vector of bit values
param.FreqSep = 500;
param.SampPerSym = 50;
param.SymRate = 400;
param.TSymRate = 1/param.SymRate;
param.FS = param.SymRate * param.SampPerSym * 100;

%% Message parameters
param.BarkerCode      = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1];     % Bipolar Barker Code
param.BarkerLength    = length(param.BarkerCode);
param.HeaderLength    = param.BarkerLength * log2(param.ModOrder) * 2;                       % Duplicate 2 Barker codes to be as a header
param.Message         = message;
param.MessageLength   = length(param.Message) + 5;                    % 'Just checking 000\n'...
param.NumberOfMessage = nummess;                                          % Number of messages in a frame
param.PayloadLength   = param.NumberOfMessage * param.MessageLength * 7; % 7 bits per characters
param.FrameSize       = (param.HeaderLength + param.PayloadLength) ...
    / log2(param.ModOrder);                                    % Frame size in symbols
param.FrameTime       = param.TSymRate * param.FrameSize;

%% Msg to bits
msgSet = zeros(param.NumberOfMessage * param.MessageLength, 1); 
for msgCnt = 0 : (param.NumberOfMessage - 1)
    msgSet(msgCnt * param.MessageLength + (1 : param.MessageLength)) = ...
        sprintf('%s %03d\n', param.Message, msgCnt);
end
bits = de2bi(msgSet, 7, 'left-msb')';
param.MessageBits = bits(:);

%% Pluto parameters
% Pluto transmitter parameters
param.PlutoCenterFrequency      = 500e6;
param.PlutoGain                 = 0;
param.PlutoFrontEndSampleRate   = param.FS;
param.PlutoFrameLength          = param.FrameSize * param.SampPerSym;

%% General parameters
param.StopTime  = 5000;