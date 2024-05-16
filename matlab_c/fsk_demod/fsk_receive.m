classdef fsk_receive
    properties
        Message
        ValidationNum
        Samples
        prmFSKReceiver
        PrintReceivedData = true
        Radio
    end

    methods
        function obj = fsk_receive(message, validationNum, samples)
            if nargin < 2
                error('At least two arguments are required.');
            end

            obj.Message = message;
            obj.ValidationNum = validationNum;
            obj.Samples = samples;

            [~, ~] = system('iio_attr -u ip:192.168.2.1 -D ad9361-phy adi,rssi-restart-mode 2');

            obj.prmFSKReceiver = radiofskreceiver_init(obj.Message, obj.ValidationNum);

            obj.Radio = sdrrx('Pluto');
            obj.Radio.RadioID = 'usb:0';
            obj.Radio.CenterFrequency = obj.prmFSKReceiver.PlutoCenterFrequency;
            obj.Radio.BasebandSampleRate = obj.prmFSKReceiver.PlutoFrontEndSampleRate;
            obj.Radio.SamplesPerFrame = obj.prmFSKReceiver.PlutoFrameLength;
            obj.Radio.GainSource = 'Manual';
            obj.Radio.Gain = obj.prmFSKReceiver.PlutoGain;
            obj.Radio.OutputDataType = 'double';
        end

        function [values, valid] = receive(obj)
            rx = FSKReceiver(...
                'ModulationOrder',                      obj.prmFSKReceiver.ModOrder, ...
                'BitInput',                             obj.prmFSKReceiver.BitInput, ...
                'FrequencySeparation',                  obj.prmFSKReceiver.FreqSep, ...
                'SamplesPerSymbol',                     obj.prmFSKReceiver.SampPerSym, ...
                'SymbolRate',                           obj.prmFSKReceiver.SymRate, ...
                'FrameSize',                            obj.prmFSKReceiver.FrameSize, ...
                'MessageBits',                          obj.prmFSKReceiver.MessageBits, ...
                'ModulatedHeader',                      obj.prmFSKReceiver.ModulatedHeader, ...
                'HeaderLength',                         obj.prmFSKReceiver.HeaderLength, ...
                'NumberOfMessage',                      obj.prmFSKReceiver.NumberOfMessage, ...
                'ValidationNum',                        obj.prmFSKReceiver.ValidationNum, ...
                'PayloadLength',                        obj.prmFSKReceiver.PayloadLength, ...
                'DesiredPower',                         obj.prmFSKReceiver.DesiredPower, ...
                'AveragingLength',                      obj.prmFSKReceiver.AveragingLength, ...
                'MaxPowerGain',                         obj.prmFSKReceiver.MaxPowerGain, ...
                'PreambleDetectionThreshold',           obj.prmFSKReceiver.PreambleDetectionThreshold, ...
                'PrintOption',                          obj.PrintReceivedData);

            values = [];
            j = 0;
            waiting = true;

            while waiting
                data = obj.Radio();
                [~, rssi] = system('iio_attr -u ip:192.168.2.1 -c -i ad9361-phy voltage0 rssi');

                valid = rx(data);
                if valid
                    j = j + 1;
                    rssi_val = str2double(strtok(rssi, ' dB'));
                    values = [values, rssi_val];
                end

                if j >= obj.Samples
                    waiting = false;
                    valid = true;
                    disp('passed');
                end
            end
            release(rx);

        end

        function releaseResources(obj)
            release(obj.Radio);
        end
    end
end
