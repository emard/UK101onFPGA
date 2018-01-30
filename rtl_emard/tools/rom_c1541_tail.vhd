	-- delete trailing "," at the above line to fix syntax error
	);
begin
	process(clk)
	begin
		if rising_edge(clk) then
			data <= romData(conv_integer(addr));
		end if;
	end process;
end architecture;

