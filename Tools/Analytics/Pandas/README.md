# Analyze data with Pandas

_**Pandas**_ is a powerful data manipulation library for Python. It provides data structures and functions to efficiently manipulate large datasets. In this guide, it will be aborded how to obtain data from our _API_ and create a DataFrame in _Pandas_.

## Requirements

- _**Google Colab**_

> **Google Colab** is a free cloud service that allows you to run Python code in a Jupyter notebook environment. It is a great tool for data analysis and machine learning. But if you prefer, you can run the code in your local environment.

## Dependencies

- _**Pandas**_
- _**Requests**_

## Code

After installing the dependencies, you can run the following code in your _Jupyter Notebook_ or _Google Colab_.

```python
import pandas as pd
import requests
```

```python
def get_data(url):
    response = requests.get(url, verify=False)
    data = response.json()
    return data
```

```python
api_url = "https://smartcampus-k8s.maua.br/api/timeseries/v0.1/smartcampusmaua/SmartLights?interval=20"
data = get_data(api_url)
```

The code above makes a simple GET request to the _API_ and returns the data in _JSON_ format. Now, we can create a _DataFrame_ with the data.

```python
df = pd.DataFrame(data)
df
```

Now that the _DataFrame_ is created, you can manipulate the data as you wish. Check  _**Pandas**_ documentation for more information.

> _**Tip**_ : The DataFrame is not so well organized, try to improve it.


## References 

- [Google Colab](https://colab.google/)
- [Requests](https://requests.readthedocs.io/en/latest/user/quickstart/#make-a-request)
- [Pandas Documentation](https://pandas.pydata.org/docs/)
