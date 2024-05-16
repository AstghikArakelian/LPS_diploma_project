classdef (StrictDefaults)FSKReceiver < matlab.System
    properties (Nontunable)
        ModulationOrder = 2;
        FrequencySeparation = 500;
        SamplesPerSymbol = 50;
        SymbolRate = 1000;
        BitInput = 1;
        BitOutput = 1;
        MessageBits = 0;
        ModulatedHeader = 0;
        FrameSize = 1133;
        HeaderLength = 13;
        NumberOfMessage = 10;
        ValidationNum = 5;
        PayloadLength = 2240;
        DesiredPower = 2
        AveragingLength = 50
        MaxPowerGain = 20
        PreambleDetectionThreshold = 0.8;
        PrintOption = false;
    end
    
    properties (Access = private)
        pAGC
        pFrameSync
        pDataDecod
        pMeanFreqOff
        pCnt
    end
    
    methods
        function obj = FSKReceiver(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access = protected)
        function setupImpl(obj, ~)
            
            obj.pAGC = comm.AGC( ...
                'DesiredOutputPower',       obj.DesiredPower, ...
                'AveragingLength',          obj.AveragingLength, ...
                'MaxPowerGain',             obj.MaxPowerGain);

            obj.pMeanFreqOff = 0;
            
            obj.pCnt = 0;
            
            obj.pFrameSync = FrameSynchronizer( ...
                'Preamble',                 obj.ModulatedHeader, ...
                'Threshold',                obj.PreambleDetectionThreshold, ...
                'OutputLength',             obj.FrameSize*obj.SamplesPerSymbol);

            obj.pDataDecod = FSKDataDecoder( ...
                'ModulationOrder',              obj.ModulationOrder, ...
                'FrequencySeparation',          obj.FrequencySeparation, ...
                'SamplesPerSymbol',             obj.SamplesPerSymbol, ...
                'SymbolRate',                   obj.SymbolRate, ...
                'HeaderLength',                 obj.HeaderLength, ...
                'MessageBits',                  obj.MessageBits, ...
                'ValidationNum',                obj.ValidationNum, ...
                'PayloadLength',                obj.PayloadLength, ...
                'PrintOption',                  obj.PrintOption);
        end
        
        function valid = stepImpl(obj, bufferSignal)
            AGCSignal = obj.pAGC(bufferSignal);                     % AGC control

            [symFrame, isFrameValid] = obj.pFrameSync(AGCSignal);   % Frame synchronization    
           
            valid = obj.pDataDecod(symFrame, isFrameValid);
        end
        
        function resetImpl(obj)
            reset(obj.pAGC);
            reset(obj.pFrameSync);
            reset(obj.pDataDecod);
            obj.pMeanFreqOff = 0;
            obj.pCnt = 0;
        end
        
        function releaseImpl(obj)
            release(obj.pAGC);
            release(obj.pFrameSync);
            release(obj.pDataDecod);
        end
        
        function N = getNumOutputsImpl(~)
            N = 1;
        end
    end
end