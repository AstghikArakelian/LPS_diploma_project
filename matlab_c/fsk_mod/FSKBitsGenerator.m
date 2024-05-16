classdef FSKBitsGenerator < matlab.System
    % Generates the bits for each frame
    
    properties (Nontunable)
        ModOrder = 2;
        NumberOfMessage = 10;
        MessageLength = 16;
        MessageBits = [];
        BarkerCode = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar Barker Code
    end
    
    properties (Access=private)
        pHeader
        pSigSrc
    end
    
    methods
        function obj = FSKBitsGenerator(varargin)
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods (Access=protected)
        function setupImpl(obj, ~)
            % Generate unipolar Barker Code and duplicate it as header
            ubc = ((obj.BarkerCode + 1) / 2)';
            temp = (repmat(ubc,1,log2(obj.ModOrder)*2))';
            obj.pHeader = temp(:);
            
            % Initialize signal source
            obj.pSigSrc = dsp.SignalSource(obj.MessageBits, ...
                'SamplesPerFrame', obj.MessageLength * 7 * obj.NumberOfMessage, ...
                'SignalEndAction', 'Cyclic repetition');
            
        end
        
        function [y, msgBin] = stepImpl(obj)
            
            % Generate message binaries from signal source.
            msgBin = obj.pSigSrc();
            
            % Append the scrambled bit sequence to the header
            y = [obj.pHeader ; msgBin];
            
        end
        
        function resetImpl(obj)
            reset(obj.pSigSrc);
        end
        
        function releaseImpl(obj)
            release(obj.pSigSrc);
        end
        
        function N = getNumInputsImpl(~)
            N = 0;
        end
        
        function N = getNumOutputsImpl(~)
            N = 2;
        end
    end
end

