classdef fsk_transmit
    
    properties
        started = false;
        Radio
        Transmitter
        prmFSKTransmitter
    end

    methods
        function obj = fsk_transmit(message, nummess)
            % Initialize system parameters
            obj.prmFSKTransmitter = radiofsktransmitter_init(message, nummess);

            % Setup the transmitter configuration
            obj.Transmitter = FSKTransmitter( ...
                'NumberOfMessage',              obj.prmFSKTransmitter.NumberOfMessage, ...
                'MessageLength',                obj.prmFSKTransmitter.MessageLength, ...
                'MessageBits',                  obj.prmFSKTransmitter.MessageBits, ...
                'ModulationOrder',              obj.prmFSKTransmitter.ModOrder, ...
                'BitInput',                     obj.prmFSKTransmitter.BitInput, ...
                'FrequencySeparation',          obj.prmFSKTransmitter.FreqSep, ...
                'SamplesPerSymbol',             obj.prmFSKTransmitter.SampPerSym, ...
                'SymbolRate',                   obj.prmFSKTransmitter.SymRate, ...
                'BarkerCode',                   obj.prmFSKTransmitter.BarkerCode);

            % Setup the radio
            obj.Radio = sdrtx('Pluto');
            obj.Radio.RadioID = 'usb:0';
            obj.Radio.CenterFrequency = obj.prmFSKTransmitter.PlutoCenterFrequency;
            obj.Radio.BasebandSampleRate = obj.prmFSKTransmitter.PlutoFrontEndSampleRate;
            obj.Radio.SamplesPerFrame = obj.prmFSKTransmitter.PlutoFrameLength;
            obj.Radio.Gain = obj.prmFSKTransmitter.PlutoGain;
        end

        function obj = transmitContinuous(obj)
            if ~obj.started
                disp('Transmission has started');
                modulated_data = step(obj.Transmitter);

                obj.Radio.transmitRepeat(modulated_data);
                obj.started = true;
            end
        end

        function obj = stopTransmission(obj)
            release(obj.Transmitter);
            release(obj.Radio);
            disp("released");
            obj.started = false;
        end
    end
end
