# Reactive Tabu Search algorithm in the Ruby Programming Language

# The Clever Algorithms Project: http://www.CleverAlgorithms.com
# (c) Copyright 2010 Jason Brownlee. Some Rights Reserved. 
# This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 2.5 Australia License.

def euc_2d(c1, c2)
  Math::sqrt((c1[0] - c2[0])**2.0 + (c1[1] - c2[1])**2.0).round
end

def cost(permutation, cities)
  distance =0
  permutation.each_with_index do |c1, i|
    c2 = (i==permutation.length-1) ? permutation[0] : permutation[i+1]
    distance += euc_2d(cities[c1], cities[c2])
  end
  return distance
end

def random_permutation(cities)
  all = Array.new(cities.length) {|i| i}
  return Array.new(all.length) {|i| all.delete_at(rand(all.length))}
end

def generate_initial_solution(cities)
  best = {}
  best[:vector] = random_permutation(cities)
  best[:cost] = cost(best[:vector], cities)
  return best
end

def is_tabu?(edges, tabuList, iteration, prohibitionPeriod)
  tabuList.each do |entry|
    if entry[:edge] == edges
      if entry[:iteration] >= iteration-prohibitionPeriod
        return true
      else 
        return false
      end
    end
  end
  return false
end

def bestNonTabuMove(candidates, tabuList, iteration)
  candidates.each do |c| 
    return c.first if !is_tabu?(c[1], tabuList, iteration)
  end
  return nil
end

def make_tabu(tabuList, edge, iteration)
  tabuList.each do |entry|
    if entry[:edge] == edge
      entry[:iteration] = iteration
      entry[:visited] += 1
      return
    end
  end
  entry = {}
  entry[:visited] = 1
  entry[:edge] = edge
  entry[:iteration] = iteration
  tabuList.push(entry)
  return entry
end

def swap(permutation)
  perm = Array.new(permutation)
  c1, c2 = rand(perm.length), rand(perm.length)
  c2 = rand(perm.length) while c1 == c2
  perm[c1], perm[c2] = perm[c2], perm[c1]
  return permutation, [c1, c2]
end

def generate_candidate(best, cities)
  candidate = {}
  candidate[:vector], edges = stochastic_two_opt(best[:vector])
  candidate[:cost] = cost(candidate[:vector], cities)
  return candidate, edges
end

def search(cities, candidateListSize, maxIterations, cycleMax, increase, decrease)
  best = generate_initial_solution(cities)
  current = best
  tabuList, prohibitionPeriod = Array.new(tabuListSize), 1
  
  avgLength = 0
  
  maxIterations.times do |iter|
    
    # todo, check for duplicates - new func
    candidates = Array.new(candidateListSize) {|i| generate_candidate(current, cities)}
    candidates.sort! {|x,y| x.first[:cost] <=> y.first[:cost]}
    bestCandidate, bestCandidateEdges = candidates.first[0], candidates.first[1]

    tabu = is_tabu?(bestCandidateEdges, tabuList, iteration, prohibitionPeriod)
    entry = make_tabu(tabuList, bestCandidateEdges, iter)
    
    
    # if permutation seen before?
    if tabu
      
      # length of time since permutation last seen?
      if iter-entry[:iteration] < 2*(cities.length-1)
        avgLength = 0.1*(iter-entry[:iteration]) + 0.9*avgLength
        prohibitionPeriod = prohibitionPeriod*increase
      end
      
    end


    
    if tabu and  < cycleMax
      
    end
    
    bestChanged = false
    best, bestChanged = bestCandidate, true if bestCandidate[:cost] < best[:cost]
    if tabu 
      # this is crap, because above we are tabu'ing a different move
      current = bestNonTabuMove(candidates, tabuList, iter)
      if current.nil?
        current = bestCandidate
        prohibitionPeriod = prohibitionPeriod*decrese
      end
    else
      current = bestCandidate if bestCandidate[:cost]<current[:cost]
    end
    
    puts " > iteration #{(iter+1)}, best: c=#{best[:cost]}"
  end
  return best
end

MAX_ITERATIONS = 100
MAX_CANDIDATES = 50
INCREASE = 1.3
DECREASE = 0.9
CYCLE_MAX = 50
BERLIN52 = [[565,575],[25,185],[345,750],[945,685],[845,655],[880,660],[25,230],[525,1000],
 [580,1175],[650,1130],[1605,620],[1220,580],[1465,200],[1530,5],[845,680],[725,370],[145,665],
 [415,635],[510,875],[560,365],[300,465],[520,585],[480,415],[835,625],[975,580],[1215,245],
 [1320,315],[1250,400],[660,180],[410,250],[420,555],[575,665],[1150,1160],[700,580],[685,595],
 [685,610],[770,610],[795,645],[720,635],[760,650],[475,960],[95,260],[875,920],[700,500],
 [555,815],[830,485],[1170,65],[830,610],[605,625],[595,360],[1340,725],[1740,245]]

best = search(BERLIN52, MAX_CANDIDATES, MAX_ITERATIONS, CYCLE_MAX, INCREASE, DECREASE)
puts "Done. Best Solution: c=#{best[:cost]}, v=#{best[:vector].inspect}"