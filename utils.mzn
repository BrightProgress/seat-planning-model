% Support function: max distance between between portions of a split Group
% Note: since the arrangement of blocks is in a cycle, distance is the minimum
% of the distances measured by traversing the cycle of Blocks forward and backward!
function var int : distance(var Groups : g) = 
    max(a in Blocks, b in Blocks where a < b)
        (if (assignment[g,a] > 0 /\ assignment[g,b] > 0) 
         then min(abs(a-b), num_blocks - abs(a-b)) 
         else 0 endif);

function var int : order(var int: size) =
    if size < 10 then
        10
    else if size < 100 then
        100
    else if size < 1000 then
        1000
    else 10000
    endif endif endif;  

function var int : lex_embedding(var int : a, var int : size_a, var int : b, var int : size_b) =
    a * order(size_b) + b;
    
function var int : lex_embedding3(var int : a, int : size_a, var int : b, int : size_b, var int : c, int : size_c) =
   lex_embedding(a, size_a, 
                 lex_embedding(b, size_b, c, size_c), 
                 order(lex_embedding(b, size_b, c, size_c)));
