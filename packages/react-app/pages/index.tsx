import { useContractWrite } from "wagmi";
import abiContract from "../abis/MarketPlace.json";
import { SocialConnect } from '@celo-org/social-connect';

export default function Home() {
  const { data, isLoading, isSuccess, write } = useContractWrite({
    address: abiContract.address,
    abi: abiContract.abi,
    functionName: "addItem",
  });

  


  return (
    <div>
      <button onClick={() => write()}>addItem</button>
      {isLoading && <div>Check Wallet</div>}
      {isSuccess && <div>Transaction: {JSON.stringify(data)}</div>}
    </div>
  );
}
