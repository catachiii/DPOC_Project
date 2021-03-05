 function aoi = LCG_generate_area_of_interest(test_point, stateSpace)
        rad = 1;
        aoi = [];
        k = 1;
        for i = -rad : rad
            for j = -rad : rad
                des = [i j] + test_point;
                if find(ismember(stateSpace,[des(1), des(2), 0], 'rows'))
                    aoi = [aoi; des];
                    k = k + 1;
                end
            end          
        end
end