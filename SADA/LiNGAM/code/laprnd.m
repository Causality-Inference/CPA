function x = laprnd(a,b,m,n)%%%a ��λ�ò�����location parameter��  b �� 0 �ǳ߶Ȳ��� ��scale parameter����m��n�ֱ��ʾ����������������������
% Reference: http://en.wikipedia.org/wiki/Laplace_distribution
    u = rand(m,n)-0.5;
    x = a - b*sign(u).*log(1-2*abs(u));
end