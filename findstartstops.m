function [startstops] = findstartstops(t,idx,idxval)  %returns a matrix of start and stop values for a given state (1-4)
    b = false;
    startstops = [];

    for i=1:length(idx)
        if idx(i)==idxval && b==false
                start = t(i);
                b=true;
        end

        if b==true && idx(i) ~= idxval
                stop = t(i);
                b=false;
                startstops = [startstops;start stop];
        end

        if i==length(idx) && b==true %edge case
                stop = t(i)+.5;
                b=false;
                startstops = [startstops;start stop];
        end

    
    end

    while length(startstops)<1000
        startstops = [startstops; 0 0];
    end


end