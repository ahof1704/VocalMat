% 1. Tail/butt location might be significantly off from elipse "rear".
% 2. Nose location might be significantly off from elipse "front".
% 3. Behavior: escorting/side-blocking.
% 4. Image-Processing problem: head-tail switch (frame 9577)
% 5. Identity switch at 22223 till 22286 (blue-red).
% 6. Suggestion: interactive mode where events detected by a classifier
%                                  trained with Nrounds but not by a classifier trained with Mrounds, are
%                                  shown to the user, and his choises determine the final number after convergence. 

% Head-Sniffing Types:
% 1. camp - no approach/depart
% 2. group - 3rd participant for part of the time

% Each mouse may
% 1. approach 1/2 mice
% 2. depart 1/2 mice
 19129-19180  35956-36021  51582-51627
 
 52927 - following the follower
 
 Check pos/neg ratio
 (don't) forbid no mouse-frame and no mouse-pair
 refesh classifier list after saving the last classifier
 add symmetry checkbox for coordinates features
 
 53748 - 2 couples
 
 6492 ?
 
 check 16816
 
     if (m(1)==1 || m(1)==3) && (m(2)==2 || m(2)==4) % filter out plausible mating 
       continue;
    end

 
 % Mating! 10.04.24 frame 500
 
 todo: send
 1. Version update.
 2. Statistics of Sniffing, Following and Proximity.