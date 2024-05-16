classdef (StrictDefaults)FSKTransmitter < matlab.System  
% Generates the FSK signal to be transmitted
    
    properties (Nontunable)
        NumberOfMessage = 10
        MessageLength = 16
        MessageBits = []
        ModulationOrder = 2;
        BitInput = 1;
        FrequencySeparation = 500;
        SamplesPerSymbol = 50;
        SymbolRate = 1000;
        BarkerCode = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar Barker Code
    end
    
    properties (Access=private)
        pBitGenerator
        pFSKModulator
        pMessage = 'Check check check';
        pHeader = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar barker-code
    end
    
    methods
        function obj = FSKTransmitter(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj)
            obj.pBitGenerator = FSKBitsGenerator( ...
                'ModOrder',                     obj.ModulationOrder, ...
                'BarkerCode',                   obj.BarkerCode, ...
                'NumberOfMessage',              obj.NumberOfMessage, ...
                'MessageLength',                obj.MessageLength, ...
                'MessageBits',                  obj.MessageBits);
            obj.pFSKModulator  = comm.FSKModulator( ...
                'ModulationOrder',              obj.ModulationOrder, ...
                'BitInput',                     obj.BitInput, ...
                'FrequencySeparation',          obj.FrequencySeparation, ...
                'SamplesPerSymbol',             obj.SamplesPerSymbol, ...
                'SymbolRate',                   obj.SymbolRate, ...
                'ContinuousPhase',              1);
        end

        function modulatedData = stepImpl(obj) 
            [transmittedBin, ~] = obj.pBitGenerator();                 % Generates the data to be transmitted
            modulatedData = obj.pFSKModulator(transmittedBin);        % Modulates the bits into FSK symbols
        end
        
        function resetImpl(obj)
            reset(obj.pBitGenerator);
            reset(obj.pFSKModulator );
        end
        
        function releaseImpl(obj)
            release(obj.pBitGenerator);
            release(obj.pFSKModulator);
        end
        
        function N = getNumInputsImpl(~)
            N = 0;
        end
    end
end

