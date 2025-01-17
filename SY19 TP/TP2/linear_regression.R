setwd("D:/A-UTC/1PEDAGOGIQUE/A2018/SY19/TP/TP2")
prostate <- read.table('D:/A-UTC/1PEDAGOGIQUE/A2018/SY19/TP/TP2/prostate.data')

#1.Apprentissage du mod�le lin�aire
lm.model <- lm(lpsa~.-train, data = prostate)
p <- length(lm.model$coefficients) - 1  #c'est la dimention des predicteurs
n <- nrow(prostate)
yi <- prostate$lpsa
yihat <- fitted(lm.model)
summary(lm.model)
#Les variables lcavol, svi et lweight sont significatives (pp-value tr�s faibles). 
#La r�gression est �galement significative.

#2.Intervalles de confiance sur les coefficients de la r�gression lin�aire.
confint(lm.model)

#3.Trac? des valeurs pr�dites en fonction des yi ainsi que la droite y=x
plot(yi, yihat, asp = 1)
abline(0, 1)

#4.Tracer les r�sidus
rres <- resid(lm.model)
#rres2 <- lm.model$residuals
plot(yihat, rres)
#Le trac? des r�sidus ne fait pas apparaitre de structures particuli�res (parabole, entonnoir, .)
#Les r�sidus standardis�s
rstd <- rstandard(lm.model)
plot(yihat, rstd)
#Les r�sidus studentis�s
rstu <- rstudent(lm.model)
plot(yihat, rstu)

#Les r�sidus en fonction des variables explicatives

attach(prostate)
varnames <- attr(lm.model$terms, "term.labels")
par(mfrow = c(length(varnames), 3))
par(mar=c(1,1,1,1))
for(name in varnames) {
  plot(get(name), rres, xlab = name)
  plot(get(name), rstd, xlab = name)
  plot(get(name), rstu, xlab = name)
}

par(mfrow = c(1, 1))
#5.QQ-plot des r�sidus
qqnorm(rres, asp = 1)
qqline(rres, dist = qnorm)

#QQ-plot des r�sidus standardis�s
qqnorm(rstd, asp = 1)
qqline(rstd, dist = qnorm)

#QQ-plot des r�sidus studentis�s
qqnorm(rstu, asp = 1)
qqline(rstu, dist = qnorm)

#6.Calcul de l'influence (hat-values, leverage, hiihii)
hv <- hatvalues(lm.model)
h <- 2*(p + 1)/n
outliers_hv <- which(hv > h)
plot(yihat, yi, asp=1)
abline(0, 1)
points(yihat[outliers_hv], yi[outliers_hv], pch = 19)

#Les r�sidus studentis�s
#rstu <- rstudent(lm.model)
outliers_rstu <- which(abs(rstu) > 2)
plot(yihat, yi, asp=1)
abline(0, 1)
points(yihat[outliers_rstu], yi[outliers_rstu], pch=19)


#Influence globale: distance de Cook
plot(lm.model, which = 4, cook.levels = c(0, 0.1))

#Synth�se: influence potentielle, r�sidus studentis�s, distance de Cook
plot(lm.model, which = 5, cook.levels = c(0, 0.1))

#7.On se limite aux pr�dicteurs significatifs.
lm.model2 <- lm(lpsa~lcavol+svi+lweight, data = prostate)
p2 <- length(lm.model$coefficients) - 1
n2 <- nrow(prostate)
yi2 <- prostate$lpsa
yihat2 <- fitted(lm.model2)
summary(lm.model2)
#La r�gression peut �tre tr�s significative sans que les pr�dicteurs 
#le soient particuli�rement (pr�dicteurs corr�l�s).
summary(lm(lpsa~pgg45+gleason, data = prostate))
#Un pr�dicteur tr�s significatif peut ne plus �tre significatif 
#lorsqu'on change l'ensemble des pr�dicteurs.
summary(lm(lpsa~gleason+lcavol, data = prostate))
summary(lm(lpsa~gleason, data = prostate))
#Le rajout d'un pr�dicteur ne fait pas syst�matiquement 
#baisser la significativit? d'un pr�dicteur.
summary(lm(lpsa ~ lcavol+lweight+age, data = prostate))$coefficients["lcavol", "Pr(>|t|)"]
summary(lm(lpsa ~ lcavol+lweight+age+lbph, data = prostate))$coefficients["lcavol", "Pr(>|t|)"]

#8-9
lm.model3 <- lm(lpsa ~ lcavol + lweight + svi, data = prostate, subset = train)
test_set3 <- model.frame(lpsa ~ lcavol + lweight + svi, data = prostate, subset = !train)
yi3 <- test_set3$lpsa

pred3 <- predict(lm.model3, newdata = test_set3, interval = "prediction")

plot(yi3, pred3[, 1], ylim = range(pred3), asp = 1)
lines(yi3, pred3[, 2])
lines(yi3, pred3[, 3])
abline(0, 1)

