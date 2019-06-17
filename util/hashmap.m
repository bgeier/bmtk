
% $Author: Rajiv Narayan [narayan@broadinstitute.org]
% $Date: Jul.01.2010 12:01:45 EDT
function hash = hashmap(varargin)
%HASHMAP create a hashmap of keys and values.
%   H = HASHMAP() Constructs an empty HashMap with the default initial
%   capacity (16) and the default load factor (0.75).
%
%   H = HASHMAP(MAP) Constructs a new HashMap with the key/value mappings
%   as the specified MAP. MAP is a 1x2 cell array with the first column
%   containing a vector or cell array of keys and the second column a
%   vector or cell array of values.
%
%   H = HASHMAP('param', value) Specifies parameters of the hashmap.
%
%   Parameters:
%       initialCapacity: the number of buckets in the hash 
%                        table at the time the hash table is created. The
%                        default is 16
%       loadFactor: is a measure of how full the hash table is allowed to
%                   get before its capacity is automatically increased. The
%                   default is 0.75
%
%   This implementation utilizes the java HashMap. For details see:    
%   http://java.sun.com/j2se/1.4.2/docs/api/java/util/HashMap.html
%   Example:
%       keyvals  = { {'foo','bar','abc'}, 1:3};
%       hash = hashmap('map', keyvals);
%       hash.get('bar')     % returns 2
%       hash.put('xyz',4)   % adds a new mapping 
%       hash.keySet         % lists all keys

pnames = {'initialCapacity', 'loadFactor', 'map'};
dflts = {16, 0.75, {}};

[eid, emsg, midx, initialCapacity, loadFactor, map] = ...
                getargs(pnames, dflts, varargin{:});

% create hash            
hash = java.util.HashMap(initialCapacity, loadFactor);

% add mappings
if ( ~isempty(map) && isequal(length(map{1}),length(map{2})))
    fprintf ('%s: hashing %d keys\n',mfilename, length(map{1}));
    iskeycell = iscell(map{1});
    isvalcell = iscell(map{2});
    
    for ii=1:length(map{1})
        
        if iskeycell
            key=map{1}{ii};
        else
            key=map{1}(ii);
        end
        
        if isvalcell
            val=map{2}{ii};
        else
            val=map{2}(ii);
        end
        
        hash.put(key, val);
    end
end

