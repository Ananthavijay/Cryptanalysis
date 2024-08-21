%%%%%%%%%%%%%%%%%%%%
% Loading the data %
%%%%%%%%%%%%%%%%%%%%

% declaration of the SBOX (needed to calculate the power hypothesis)
SBOX =[099 124 119 123 242 107 111 197 048 001 103 043 254 215 171 118 ...
202 130 201 125 250 089 071 240 173 212 162 175 156 164 114 192 ...
183 253 147 038 054 063 247 204 052 165 229 241 113 216 049 021 ...
004 199 035 195 024 150 005 154 007 018 128 226 235 039 178 117 ...
009 131 044 026 027 110 090 160 082 059 214 179 041 227 047 132 ...
083 209 000 237 032 252 177 091 106 203 190 057 074 076 088 207 ...
208 239 170 251 067 077 051 133 069 249 002 127 080 060 159 168 ...
081 163 064 143 146 157 056 245 188 182 218 033 016 255 243 210 ...
205 012 019 236 095 151 068 023 196 167 126 061 100 093 025 115 ...
096 129 079 220 034 042 144 136 070 238 184 020 222 094 011 219 ...
224 050 058 010 073 006 036 092 194 211 172 098 145 149 228 121 ...
231 200 055 109 141 213 078 169 108 086 244 234 101 122 174 008 ...
186 120 037 046 028 166 180 198 232 221 116 031 075 189 139 138 ...
112 062 181 102 072 003 246 014 097 053 087 185 134 193 029 158 ...
225 248 152 017 105 217 142 148 155 030 135 233 206 085 040 223 ...
140 161 137 013 191 230 066 104 065 153 045 015 176 084 187 022];

numberOfTraces = 150;           
traceSize = 550000;             

offset = 0;                     
segmentLength = 30000;          

columns = 16;
rows = numberOfTraces;

traces = myload('traces-unknown_key.bin', traceSize, offset, segmentLength, numberOfTraces);
plaintext = myin('plaintext_unknown_key.txt', columns, rows);
ciphertext = myin('ciphertext_unknown_key.txt', columns, rows);

%%%%%%%%%%%%%%%%
% Key recovery %
%%%%%%%%%%%%%%%%

byteStart = 1;
byteEnd = 16;
keyCandidateStart = 0;
keyCandidateStop = 255;
result = zeros(1, 16);

for BYTE = byteStart : byteEnd
% Create the power hypothesis
% The number 256 represents all possible bytes (e.g., 0x00..0xFF).
powerHypothesis = zeros(numberOfTraces, 256);
    for K = keyCandidateStart : keyCandidateStop
        for N = 1 : numberOfTraces
            XOR = bitxor(plaintext(N, BYTE), K);
            sboxVal = SBOX(XOR + 1);
            Hw = byte_Hamming_weight(sboxVal + 1);
            powerHypothesis(N, K + 1) = Hw;
        end
    end
% Calculate the Correlation Coefficient
    CC = mycorr(powerHypothesis, traces);

% The byte with the Highest Correlation Coefficient is the correct byte of the key
keyVal = 0;
segIndex = 0;
HighestCoef = 0;
    for K = keyCandidateStart : keyCandidateStop
        for seg = 1 : segmentLength
            if(CC(K + 1, seg) > HighestCoef)
                HighestCoef = CC(K + 1, seg);
                kIndex = K;
                segIndex = seg;
            end
        end
    end
    kIndex;
    result(1, BYTE) = kIndex;
end

for i = 1 : 16
    fprintf ( "Byte %d of the key is 0x%2.2X \n ", i , result(i) );
end