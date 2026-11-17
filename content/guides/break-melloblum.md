---
title: "BREAK Melloblum"
date: 2026-11-16
description: "How to use Melloblum as a Grass break."
draft: false
---

![Melloblum](/images/aniimo/melloblum.png)

I really like Melloblum. She started growing on me as a
support for Irisalis in Egg Heist. I always wanted to use
her more, but Grass is a pretty awkward element to get 
advantage of. And she, in particular, requires a team that
just wants to crit.

So, when I realized that she has the highest BREAK stat of
any non-BREAK Aniimo, I got excited.

## Contents

- [Why Melloblum](#why-melloblum)
- [Kit](#kit)
- [Items](#items)
- [Results](#results)
- [Where it falls off](#where-it-falls-off)

## Why Melloblum

As mentioned, she has the highest BREAK stat of any non-BREAK
Aniimo. At 91, she is only a few points shy of staples of the
class like Panpanta. She has the same HP stat as Inferlupa, 
and better ATK stat than most breaks.

She also has limited competition: Grass doesn't have good
BREAK Aniimo. Pomawk is the best and... Well, let's just say
Pomawk is no Inferlupa. The bar for her to meet is low. 

### The "but" and the math

She does have a few problems: Even though her stats are solid
and her range makes her as hard to take down as other BREAK,
she lacks break skills. Let me explain:

The damage to the break gauge is calculated with the
following formula: 

```
(BREAK of attacker - BREAK defense of target) * skill might * skill break multiplier * break efficiency bonuses
```

Each skill has a might (the "damage" it does) and a break
bonus. For most Aniimo, that break bonus is set to 1. I.e.
no effect. For BREAK Aniimo, it is set to 1.5. I.e. it does
50% more damage to the gauge than a normal skill would do.

When we add that she still has lower BREAK than actual
BREAK Aniimo, this compounds. We can mitigate with the 15%
break efficiency Turbo gives, but that is just not enough.

So, let's solve the problem.

## Kit

When quality is not enough, one simply has to rely on
quantity.

Melloblum's kit is interesting. We will be using two
skills: Thorny Blessing and Blasting Roses. The first one
makes it so critical hits do one more tick of 25 might
damage once every 0.5s. Blasting Roses launches four
petals (each with might 10).

I counted frames for Blasting Roses and the animation lasts
about 1.5s. Which means, Thorny Blessing can activate
three times assuming all do critical hit damage.

This is important: Each of those activations counts as
damage to the gauge.

The math for the gauge depletion (assuming Turbo's bonus)
then is:

```
(91 * 10 * 1.15) * 4 + 91 * 25 * 1.15 * 3 = 12034.75
```

Which is not that far from what the core skill from Pomawk
does:

```
107 * 79 * 1.50 = 12679.5
```

And because Melloblum's passive makes her skills more
energy efficient and she is long range, this already makes
her more interesting than Pomawk!

However, for this to work, we need crits...

## Items

Enter the breathbinder sash. At level 15, when fully
stacked, it adds 99% critical hit rate to the wearer. Because
all Aniimo have a base 10% critical hit ratio that means
guaranteed crits!

![The breathbinder sash loop](/images/breathbinder-sash.png)

This also creates an easy and obvious flow that synergizes
with her setup kit:

You start by engaging with an auto attack. This changes the
status of Melloblum to "In Combat" and activates the item.

Then, setup. Pop your Turbo buff. Start Thorny Blessing.
Maybe throw some of the extra crit damage buffs from
Tromber. By the time you are done setting up, you should
have 3 stacks. If not, throw a few more autos to reduce
energy usage of your skills.

And then... Unload. Blasting Roses on cast consumes the
stacks from the item and gives you 3s of consecutive crits.
Because the cooldown from the roses is 1s, you should have
a couple of safe casts of full crits.

## Results

On testing, at level 60 and with just enough BREAK
investment to reach 8 potential, she destroyed Omega
Sherro's gauge in about 10 seconds.

And because she can also pack a punch, she finished the
battle before it recovered from the break status.

The "Support" Aniimo :).

## Where it falls off

She is still not a break. In neutral matchups, Inferlupa
is probably still a better option. It is also worth saying
again, that this is all with Turbo's buff. So she needs to
take two slots in the team.

But Turbo works on any team. And if you need a range break
(there are not many). Or if you are in Holo Battle
Interlink and need both a break and to support a bunch of
crit horny DPS like Thornblade and Irisalis.

She got you covered.

---

Aniimo artwork belongs to Hero Games and is used here for
illustrative purposes in a fan-made guide.
