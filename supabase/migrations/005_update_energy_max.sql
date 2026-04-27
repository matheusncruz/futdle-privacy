-- Atualiza energia máxima de 5 para 25
alter table user_energy
  drop constraint energy_max,
  add constraint energy_max check (current_energy >= 0 and current_energy <= 25),
  alter column current_energy set default 25;

-- Atualiza jogadores que tinham energia máxima (5) para o novo máximo (25)
update user_energy set current_energy = 25 where current_energy = 5;
