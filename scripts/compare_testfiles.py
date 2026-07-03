import numpy

with open("testfiles/data.txt", "r") as data, open("testfiles/verify.txt") as out:
    mis_n = 0
    line = 1
    # while True:
    #     try:
    #         dat_line = data.readline()
    #         dat_line = dat_line.split()[1:]
    #         dat_line ="".join(dat_line)
    #         verify_line = out.readline()
    #         print(dat_line)
    #         if dat_line == verify_line[:len(dat_line)]:
    #             print(f"Line {line} OK.")
    #         else:
    #             print(f"Line {line} mismatched")
    #         line = line+1
    #     except EOFError:
    #         print(f"Done Reading. {mis_n} number of mismatches in total.")
    #         break
    for verify_line in out:
        dat_line = data.readline()
        dat_line = dat_line.split()[1:]
        dat_line = "".join(dat_line)
        if dat_line == verify_line[:len(dat_line)]:
            print(f"Line {line} OK.")
        else:
            mis_n += 1
            print(f"Line {line} mismatched")
        line = line+1
    else:
        print(f"Done reading. Total of {mis_n} number of mismatches.")
