#include <string>
#include <vector>
#include <algorithm>
#include <functional>
#include <iostream>

template <class T, class V>
auto map1 = [](const std::vector<T> &from, std::function<V(const T)> fn) {
  using namespace std;
  std::vector<V> b;
  int x = 0;
  for (x = 0; x < from.size(); x++)
  {
    b.push_back(fn(from[x]));
  }
  return b;
};

template <class T, class V>
auto map2 = [](const std::vector<T> &from, std::function<V(const T)> fn, std::vector<V> &b) {
  using namespace std;
  int x = 0;
  for (x = 0; x < from.size(); x++)
  {
    b.push_back(fn(from[x]));
  }
  return b;
};

template <class T, class V>
auto map_index = [](const std::vector<T> &from, std::function<V(const T, int)> fn) {
  using namespace std;
  std::vector<V> b;
  auto size = from.size();
  for (int index = 0; index < size; index++)
  {
    b.push_back(fn(from[index], index));
  }
  return b;
};

auto range(int start, int end)
{
  using namespace std;
  std::vector<int> v(end - start);
  generate(v.begin(), v.end(), [n = start]() mutable { return n++; });
  return move(v);
}

template <class T>
auto each(const std::vector<T> &vec, std::function<void(const T)> fn)
{
  for (auto &v : vec)
  {
    fn(v);
  }
}

template <class T>
auto filter(const std::vector<T> &vec, std::function<bool(T)> fn)
{
  std::vector<T> new_vec;
  for (auto &v : vec)
  {
    if (fn(v))
    {
      new_vec.push_back(v);
    }
  }
  return new_vec;
}

auto starts_with(const std::string &s, char i)
{
  return s.size() == 0 ? false : s[0] == i;
}

bool starts_with(const std::string &s, const std::string &i)
{
  return s.size() == 0 ? false : std::to_string(s[0]) == i;
}

template <class T>
auto slice(std::vector<T> vec, int start, int end = -1)
{
  return std::vector<T>(vec.begin() + start, end == -1 ? vec.end() : vec.begin() + end);
}

template <class T>
auto contains(std::vector<T> vec, const T &value)
{
  for (auto &x : vec)
  {
    if (value == x)
    {
      return true;
    }
  }
  return false;
}

template <class T>
std::vector<T> push_front(std::vector<T> vec, T val)
{
  std::vector<T> vec2;
  vec2.push_back(val);
  for (auto &x : vec)
  {
    vec2.push_back(x);
  }
  return vec2;
}

bool string_begins_with(const std::string &src, const std::string &with)
{
  if (with.size() > src.size())
  {
    return false;
  }
  for (int x = 0; x < with.size(); x++)
  {
    if (src[x] != with[x])
    {
      return false;
    }
  }
  return true;
}

int proxied_main(const std::string &path)
{
  char psBuffer[128];
  FILE *pPipe;

  /* Run DIR so that it writes its output to a pipe. Open this
    * pipe with read text attribute so that we can read it
    * like a text file.
    */

  if ((pPipe = _popen((path).c_str(), "rt")) == NULL)
    exit(1);

  /* Read pipe until end of file, or an error occurs. */

  while (fgets(psBuffer, 128, pPipe))
  {
    puts(psBuffer);
  }

  /* Close pipe and print return value of pPipe. */
  if (feof(pPipe))
  {
    return _pclose(pPipe);
  }
  else
  {
    printf("Error: Failed to read the pipe to the end.\n");
  }

  return 0;
}

std::string flatten_string_vectors(const std::vector<std::vector<std::string>> &slices)
{
  std::string args_str = "";
  for (auto &x : slices)
  {
    for (auto &y : x)
    {
      args_str += " " + y;
    }
  }
  return args_str;
}

int main(int argc, const char **argv)
{
  using namespace std;
  typedef pair<string, string> string_pair;
  typedef pair<int, int> int_pair;
  typedef vector<string> string_vector;
  typedef vector<int> int_vector;

  string_vector args = map1<int, string>(range(1, argc), [&](int x) { return string(argv[x]); });
  // CMake puts the sysroot as the first argument. Get rid of it
  args = filter<string>(args, [](string item) { return !string_begins_with(item, "--sysroot"); });

  auto res = filter<int>(
      map_index<string, int>(args, [&](string s, int index) { return starts_with(s, '-') ? index : -1; }),
      [](int index) { return index != -1; });

  // Find the start index of the arg with hyphen and the end (where the next arg with hyphen begins).
  auto slice_indices = map_index<int, int_pair>(res, [res](int idx, int index) { return int_pair(idx, (index + 1) >= res.size() ? -1 : res[(index + 1)]); });

  // Transform indices into string vectors.
  auto slices = map1<int_pair, vector<string>>(slice_indices, [args](int_pair pair) { return slice(args, pair.first, pair.second); });

  // Flags which are for some reason added. CCPSX breaks when unknown stuff is specified.
  string_vector existing_flags = {"-MT", "-MD", "-MF"};

  // only keep related slices
  slices = filter<string_vector>(slices, [existing_flags](string_vector vec) {
    int_vector exceptions;
    map2<string, int>(
        existing_flags, [vec](string x) { return string_begins_with(vec[0], x) ? 1 : 0; }, exceptions);
    exceptions = filter<int>(exceptions, [](int x) { return x == 1; });
    return exceptions.size() == 0;
  });

  // The first slice are usually the input files
  auto first_slice = slice(args, 0, res[0]);

  // Add it to the rest of the args
  slices = push_front(slices, first_slice);

  auto path = string("CCPSX.EXE ") + flatten_string_vectors(slices);
  cout << "Proxying to: " + path;

  // Run the subprocess.
  return proxied_main(path);
}
