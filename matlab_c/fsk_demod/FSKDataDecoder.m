classdef FSKDataDecoder < matlab.System
    properties (Nontunable)
        ModulationOrder = 2;    
        FrequencySeparation = 500;
        SamplesPerSymbol = 50;
        SymbolRate = 1000;     
        ModulatedHeader = 0;
        MessageBits;
        ValidationNum = 5;
        HeaderLength = 26;
        PayloadLength = 2240;
        NumberOfMessage = 10;
        BerMask = [];
        PrintOption = false;
    end
    
    properties (Access = private)
        pPayloadLength
        pFSKDemodulator
    end
    
    methods
        function obj = FSKDataDecoder(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        function setupImpl(obj, ~, ~)
            coder.extrinsic('sprintf');
            
            obj.pFSKDemodulator = comm.FSKDemodulator( ...
                'ModulationOrder',              obj.ModulationOrder, ...
                'FrequencySeparation',          obj.FrequencySeparation, ...
                'SamplesPerSymbol',             obj.SamplesPerSymbol, ...
                'SymbolRate',                   obj.SymbolRate, ...
                'BitOutput',                    true);
        end
        
        function  valid = stepImpl(obj, data, isValid)
            valid = 0;
            if isValid
                % Phase ambiguity estimation
                phaseEst = round(angle(mean(conj(obj.ModulatedHeader) .* data(1:obj.HeaderLength/2)))*2/pi)/2*pi;

                % Compensating for the phase ambiguity
                phShiftedData = data .* exp(-1i*phaseEst);

                % Demodulating the phase recovered data only payload part
                demodOut = obj.pFSKDemodulator(phShiftedData);

                msgDetect = comm.PreambleDetector(Preamble=obj.MessageBits, ...
                    Input="Bit", Detections="All");

                idx = msgDetect(demodOut);
                if length(idx) > obj.ValidationNum
                    valid = 1;
                end
            end
        end
        
        function resetImpl(obj)
            reset(obj.pFSKDemodulator);
        end
        
        function releaseImpl(obj)
            release(obj.pFSKDemodulator);
        end
    end
end

