// Index values, observations, and covariates.
data {
  int<lower = 1> N;                      // Number of observations.
  int<lower = 1> K;                      // Number of groups.
  int<lower = 1> I;                      // Number of observation-level covariates.
  
  real intent[N];                        // Vector of observations.
  int<lower = 1, upper = K> g[N];        // Vector of group assignments.
  int brand[N];                          // Vector of brands covariates.
  vector[N] price;                       // Vector of price covariates.
  
  real gamma_mean;                       // Mean for the hyperprior on gamma.
  real<lower = 0> gamma_var;             // Variance for the hyperprior on gamma.
  real<lower = 0> tau_min;               // Minimum for the hyperprior on tau.
  real<lower = 0> tau_max;               // Maximum for the hyperprior on tau.
  real<lower = 0> sigma_min;             // Minimum for the hyperprior on tau.
  real<lower = 0> sigma_max;             // Maximum for the hyperprior on tau.
}

// Parameters and hyperparameters.
parameters {
  matrix[K, (I - 1)] alpha;              // Matrix of observation-level brand coefficients.
  vector[K] beta;                        // Vector of observation-level price coefficients.
  real gamma;                            // Mean of the population model.
  real<lower=0> tau;                     // Variance of the population model.
  real<lower=0> sigma;                   // Variance of the observation model.
}

// Hierarchical regression.
model {
  // Declare mu for use in the linear model.
  vector[N] mu;
  
  // Hyperpriors and prior.
  gamma ~ normal(gamma_mean, gamma_var);
  tau ~ uniform(tau_min, tau_max);
  sigma ~ uniform(sigma_min, sigma_max);

  // Population model and likelihood.
  for (k in 1:K) {
    alpha[k,] ~ normal(gamma, tau);
    beta[k] ~ normal(gamma, tau);
  }
  for (n in 1:N) {
    mu[n] = alpha[g[n], brand[n]] + beta[g[n]] * price[n];
  }
  intent ~ normal(mu, sigma);
}

// Generate predictions using the posterior.
generated quantities {
  vector[N] mu_pc;                       // Declare mu for predicted linear model.
  real intent_pc[N];                     // Vector of predicted observations.

  // Generate posterior prediction distribution.
  for (n in 1:N) {
    mu_pc[n] = alpha[g[n], brand[n]] + beta[g[n]] * price[n];
    intent_pc[n] = normal_rng(mu_pc[n], sigma);
  }
}
