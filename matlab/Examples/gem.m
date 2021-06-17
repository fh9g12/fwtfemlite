function v = gem(theta,u,alpha,beta,Lambda,gamma)
	v = [u.*(sind(alpha).*sind(theta).*sind(Lambda + gamma) + sind(Lambda - beta).*sind(Lambda + gamma).*cosd(alpha).*cosd(theta) + cosd(alpha).*cosd(Lambda - beta).*cosd(Lambda + gamma));
	 u.*(-(sind(Lambda).*sind(Lambda + gamma) + cosd(Lambda).*cosd(theta).*cosd(Lambda + gamma)).*sind(beta).*cosd(alpha) + (sind(Lambda).*cosd(theta).*cosd(Lambda + gamma) - sind(Lambda + gamma).*cosd(Lambda)).*cosd(alpha).*cosd(beta) + sind(alpha).*sind(theta).*cosd(Lambda + gamma));
	 u.*(sind(alpha).*cosd(theta) - sind(theta).*sind(Lambda - beta).*cosd(alpha))];
end