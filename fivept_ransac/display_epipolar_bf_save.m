function [matchings, xy1, xy2, image1, image2]=display_epipolar_bf_save(path_all, i, j, K1, K2)

if i<j
    [matchings, xy1, xy2, image1, image2]=display_pure_bf(path_all, i, j);
else
    [matchings, xy1, xy2, image1, image2]=display_pure_bf_rev(path_all, i, j);
end;

x1=cat(1, xy1(1:2,:), ones(1, length(xy1)));
x2=cat(1, xy2(1:2,:), ones(1, length(xy2)));
x1=inv(K1)*x1;
x2=inv(K2)*x2;


pose=iterative_2_view(x1, x2, matchings, [1:length(matchings)]);
[ok, m_e]=remove_points2(pose, x1, x2, matchings, K1, K2, image1, image2,1);
matchings=matchings(:,ok);


heat_mapped_matches(image1, image2, xy1(1:2,matchings(1,:)), xy2(1:2,matchings(2,:)), ['bf_',num2str(i), '_', num2str(j), 'a.png'], ['bf_',num2str(i), '_', num2str(j), 'b.png'] );


