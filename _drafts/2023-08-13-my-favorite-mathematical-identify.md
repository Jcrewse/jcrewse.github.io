---
title: My Favorite Mathematical Identity
date: 2023-08-14 00:00:00 +0600
categories: [PHYSICS, MATH]
math: true
---

If you have spent enough time around math enthusiasts it is likely you have encountered the question: "What is the coolest mathematical expression?"

There are quite a few expressions that you could choose, depending on your favorite flavor of mathematics. A top contender is often Euler's identity  

$$
e^{i\pi} + 1 = 0.
$$  

It's an easy choice as it contains at least five of mathematic's most notorious actors: Euler's number (the exponential), the complex numbers, pi, zero and one. Its elegance is extremely hard to top. 

As a physicist and certified Euler fan, I am quite partial to another contribution from the swiss polymath. Found simultaneously by the equally influential French mathematician Joseph-Louis Lagrange, the Euler-Lagrange equation is written  

$$
\frac{d}{dt}\bigg(\frac{\partial L}{\partial \dot{q}} \bigg) = \bigg(\frac{\partial L}{\partial q}\bigg).
$$  

The beauty in this expression lies in the fact that this simple combination of derivatives describes the vast majority of the physical world of everyday life -- classical mechanics. The mysteries of motion are solved once we know how to describe the kinetic and potential energy of a system, the sum of which is known as the "Lagrangian" $L$. Moreover, and perhaps even more aesthetically pleasing, this Lagrangian need not be written in terms of positions, or momentum, or angles, or any particular coordinate at all. The "generalized" coordinates $q$ may be selected in whichever way proves to be most convenient for the problem at hand. Certainly elegant. Definitely cool. 

But I am here to talk about **my** favorite mathematical identity. While I am enamored by the beauty and elegance of Euler's identity or the Euler-Lagrange equations, my favorite expression is more of a clever tool than it is a beautiful statement. Used widely in quantum mechanics, electrodynamics, fourier analysis and really any place that is interested in phenomenon that can be described by complex exponential, my favorite mathematical expression is the connection between the complex exponential and the Dirac-delta function  

$$
\int d^3r e^{i\mathbf{q}\cdot\mathbf{r}} = (2\pi)^3 \delta(\mathbf{q}).
$$  

This expression, while not as aesthetically pleasing as other contenders, has a special place in my heart. Want to expand a quantum wave function? This will show up. Want to prove identities in electrodynamics? This will show up? Want to perform Fourier analysis? This will show up. 

Not only is this identity very useful, but it even calls into question fundamental notions in calculus. What does it mean to integrate a non-converging, oscillating, complex-valued function over all real-space? It is meant instead to be taken over the space of distributions, which alters many of the standard notions of calculus, but was cleverly utilized by physicists before mathematicians developed rigorous descriptions of such techniques. 