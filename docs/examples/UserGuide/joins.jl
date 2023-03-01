using Tidier

# Let's generate two data frames to join on.

df1 = DataFrame(a = ["a", "b"], b = 1:2);
df2 = DataFrame(a = ["a", "c"], c = 3:4);