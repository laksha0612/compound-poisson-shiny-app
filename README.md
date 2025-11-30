# Compound Poisson Explorer 💡  
Interactive R Shiny Simulator for the Compound Poisson Process

---

## 📘 Definition: Compound Poisson Process

A compound Poisson process is defined as:

$S(t) = \sum_{i=1}^{N(t)} X_i$

Where:

- $N(t) \sim \text{Poisson}(\lambda t)$  
- $X_i \overset{iid}{\sim} \text{Exp}(\mu)$  

This process appears in insurance risk theory, queueing, finance, and reliability modeling.

---

## 📐 Conditional Distribution of $S(t)$

Given $N(t)=n$:

$S(t)\mid N(t)=n \sim \text{Gamma}(n,\mu)$

Density:

$$
f_{S\mid N}(s\mid n) = \frac{\mu^{n} s^{\,n-1} e^{-\mu s}}{(n-1)!}, \quad s>0
$$




---

## 📊 Unconditional/Total Distribution

Unconditional density is a Poisson–Gamma infinite mixture:

$$
f_{S(t)}(s)
= \sum_{n=1}^{\infty} P[N(t)=n] \, f_{S\mid N}(s\mid n)
$$

Expanding:

$$
f_{S(t)}(s)
= e^{-\lambda t} \sum_{n=1}^{\infty}
\frac{(\lambda t)^n}{n!} \,
\frac{\mu^{n} s^{\,n-1} e^{-\mu s}}{(n-1)!}
$$


There is a probability mass at zero:

$P[S(t)=0] = e^{-\lambda t}$

---

## 🧮 Mean and Variance

For $X \sim \text{Exp}(\mu)$:

- $\mathbb{E}[X] = \frac{1}{\mu}$
- $\mathbb{E}[X^2] = \frac{2}{\mu^2}$

Therefore:

$\mathbb{E}[S(t)] = \frac{\lambda t}{\mu}$

$\mathrm{Var}(S(t)) = \frac{2\lambda t}{\mu^2}$

---

## 🔁 Large-Time Approximation (CLT)

When $\lambda t$ is large:

$S(t)
\approx
\mathcal{N}\left(
\frac{\lambda t}{\mu},
\frac{2\lambda t}{\mu^2}
\right)$

---

## 📊 Histogram Distribution at Key Times

The Shiny app includes histograms for:

- $t = 10$  
- $t = 100$  
- $t = 1000$  
- $t = 10000$

As $t$ increases:

- the distribution shifts right  
- variance increases  
- by $t=1000$ and $10000$, the distribution becomes close to Normal

---

## 🎛 Sensitivity Insights

### Effect of Arrival Rate $\lambda$
- Increases frequency of jumps  
- Increases both mean and variance of $S(t)$  

### Effect of Jump Rate $\mu$
- Since mean jump size = $1/\mu$  
  - Decreasing $\mu$ produces bigger jumps  
  - Increasing $\mu$ produces smaller jumps  

### Interaction
- $\lambda$ controls *how many* jumps  
- $\mu$ controls *how big* each jump is  

---

## 🖥️ R Shiny App Features

- Live simulation of $S(t)$  
- Adjustable parameters:  
  - Poisson rate $\lambda$  
  - Exponential rate $\mu$  
  - Time horizon $T$  
  - Number of Monte Carlo simulations  
- Process path plot  
- Final-time histogram  
- Theoretical mean & variance shown dynamically  
- Resimulation button  

---


See full Shiny app code: [app.R](app.R)

## 🖋️ Author
Laksha Bhatt



