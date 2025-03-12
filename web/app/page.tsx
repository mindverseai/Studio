import Link from "next/link";
import Loading from "@/app/components/base/loading";
import { API_PREFIX, PUBLIC_API_PREFIX } from "@/config";

const Home = async () => {
  console.log("API_PREFIX:", API_PREFIX);
  console.log("PUBLIC_API_PREFIX:", PUBLIC_API_PREFIX);
  return (
    <div className="flex flex-col justify-center min-h-screen py-12 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-md">
        <Loading type="area" />
        <div className="mt-10 text-center">
          <Link href="/apps">🚀</Link>
        </div>
      </div>
    </div>
  );
};

export default Home;
